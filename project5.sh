#!/bin/bash
# MySQL config file
MYSQL_CONFIG_FILE="$HOME/.testdb.cnf"
MYSQL_TABLE="files"
LOGFILE="/tmp/file_organizer_log.txt"
> "$LOGFILE"

# Check for dialog installation
if ! command -v dialog &> /dev/null; then
    echo "The 'dialog' utility is required but not installed. Please install it using 'sudo apt install dialog'"
    exit 1
fi

# Prompt for operation
action=$(dialog --clear --stdout --title "File Organizer" \
    --menu "Choose an option:" 15 50 2 \
    1 "Organize files" \
    2 "Undo last organization")

clear

if [[ "$action" == "2" ]]; then
    # Ask which directory to restore
    DIRECTORY=$(dialog --stdout --title "Undo Operation" --inputbox "Enter the full path of the directory to restore:" 8 60)
    clear

    if [ ! -d "$DIRECTORY" ]; then
        echo "Directory does not exist. Exiting."
        exit 1
    fi

    echo "Restoring files to original directories under $DIRECTORY..."
    # Fetch records for this directory and restore
    mysql --defaults-extra-file="$MYSQL_CONFIG_FILE" -sN -e \
        "SELECT path, original_folder, name FROM $MYSQL_TABLE WHERE original_folder = '$DIRECTORY';" \
    | while IFS=$'\t' read -r fullpath origdir filename; do
        current_location=$(find "$origdir" -type f -name "$filename" 2>/dev/null)
        if [[ -n "$current_location" && "$current_location" != "$fullpath" ]]; then
            mv "$current_location" "$origdir/$filename"
            echo "Restored $filename to $origdir"
        fi
    done

    ORG_FOLDERS=("Images" "Documents" "Music" "Videos" "Archives" "Scripts")
    for d in "${ORG_FOLDERS[@]}"; do
        full_path="$DIRECTORY/$d"
        if [ -d "$full_path" ] && [ -z "$(ls -A "$full_path")" ]; then
            rmdir "$full_path"
            echo "Removed empty directory: $d"
        fi
    done

    echo "Undo complete."
    exit 0
fi

# ============================
# ORGANIZATION MODE
# ============================
dialog --msgbox "Press OK to start organizing..." 6 40

choice=$(dialog --clear --stdout --title "File Organizer - Choose Category" \
    --menu "Select what to organize:" 20 60 7 \
    1 "Organize everything" \
    2 "Only Images" \
    3 "Only Documents" \
    4 "Only Music" \
    5 "Only Videos" \
    6 "Only Archives" \
    7 "Only Scripts")

clear

DIRECTORY=$(dialog --stdout --title "Select Directory" --inputbox "Enter the full path of the directory to organize:" 8 60)
clear

if [ ! -d "$DIRECTORY" ]; then
    echo "Invalid directory. Exiting."
    exit 1
fi

declare -A FILE_TYPES
case $choice in
    1)
        FILE_TYPES=( 
            ["Images"]="jpg jpeg png gif"
            ["Documents"]="pdf docx txt pptx"
            ["Music"]="mp3 wav"
            ["Videos"]="mp4 mkv mov"
            ["Archives"]="zip tar gz rar"
            ["Scripts"]="py sh js"
        )
        ;;
    2) FILE_TYPES=( ["Images"]="jpg jpeg png gif" ) ;;
    3) FILE_TYPES=( ["Documents"]="pdf docx txt pptx" ) ;;
    4) FILE_TYPES=( ["Music"]="mp3 wav" ) ;;
    5) FILE_TYPES=( ["Videos"]="mp4 mkv mov" ) ;;
    6) FILE_TYPES=( ["Archives"]="zip tar gz rar" ) ;;
    7) FILE_TYPES=( ["Scripts"]="py sh js" ) ;;
    *) echo "Invalid choice. Exiting."; exit 1 ;;
esac

for folder in "${!FILE_TYPES[@]}"; do
    [ ! -d "$DIRECTORY/$folder" ] && mkdir -p "$DIRECTORY/$folder"
done

get_folder_for_ext() {
    local ext="$1"
    for folder in "${!FILE_TYPES[@]}"; do
        for match in ${FILE_TYPES[$folder]}; do
            if [[ "$ext" == "$match" ]]; then
                echo "$folder"
                return
            fi
        done
    done
    echo ""
}

total_moved=0
for file in "$DIRECTORY"/*; do
    [ -f "$file" ] || continue
    full_path=$(realpath "$file")
    filename=$(basename "$file")
    ext="${filename##*.}"
    ext_lower=$(echo "$ext" | tr '[:upper:]' '[:lower:]')

    folder=$(get_folder_for_ext "$ext_lower")
    [[ -z "$folder" ]] && continue

    tracked=$(mysql --defaults-extra-file="$MYSQL_CONFIG_FILE" -sse \
        "SELECT COUNT(*) FROM $MYSQL_TABLE WHERE path = '$full_path';")

    if [ "$tracked" -eq 0 ]; then
        mysql --defaults-extra-file="$MYSQL_CONFIG_FILE" -e \
            "INSERT INTO $MYSQL_TABLE (path, name, ext, original_folder)
             VALUES ('$full_path', '$filename', '$ext_lower', '$DIRECTORY');"
    fi

    mv "$file" "$DIRECTORY/$folder/"
    echo "Moved $filename to $folder/" | tee -a "$LOGFILE"
    ((total_moved++))
done

echo "-----------------------------------"
echo "📦 Organization Summary"
echo "Total files moved: $total_moved"
echo "Details logged at: $LOGFILE"
echo "-----------------------------------"
