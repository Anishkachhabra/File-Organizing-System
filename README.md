# File Organization System for Linux

This script provides a simple, dialog-driven file organization system for Linux. It allows you to automatically categorize files in a specified directory into predefined folders based on their file extensions. It also offers an "undo" functionality to move the organized files back to their original location.

## Features

* **Interactive Menu:** Uses the `dialog` utility to provide a user-friendly text-based menu for selecting actions.
* **Organize Files:**
    * Offers options to organize all supported file types or specific categories (Images, Documents, Music, Videos, Archives, Scripts).
    * Prompts for the directory you want to organize.
    * Creates destination folders within the specified directory if they don't exist.
    * Moves files to their respective category folders based on their extensions.
    * Logs the file movements to `/tmp/file_organizer_log.txt`.
* **Undo Last Organization:**
    * Prompts for the directory that was organized.
    * Restores files from the category folders back to their original location within the specified directory.
    * Removes empty category folders after restoring files.
* **MySQL Integration:**
    * Uses a MySQL database to keep track of the original location of the files before organization.
    * Requires a MySQL configuration file at `$HOME/.testdb.cnf` with the necessary credentials.
    * Creates a table named `files` (if it doesn't exist) to store file paths, names, extensions, and their original folders.

## Prerequisites

* **Linux Operating System:** This script is designed for Linux environments.
* **Bash:** The script is written in Bash.
* **dialog:** The `dialog` utility is required for the interactive menu. You can typically install it using your distribution's package manager (e.g., `sudo apt install dialog` on Debian/Ubuntu, `sudo yum install dialog` on Fedora/CentOS).
* **MySQL Client:** The `mysql` command-line client needs to be installed to interact with the MySQL database.
* **MySQL Server:** You need a running MySQL server instance.
* **MySQL Configuration:** A MySQL configuration file must exist at `$HOME/.testdb.cnf` with the necessary credentials to connect to your MySQL database. The file should look something like this:

    ```cnf
    [client]
    user=your_mysql_user
    password=your_mysql_password
    host=localhost  # Or your MySQL server address
    database=your_database_name # Replace with your desired database name
    ```

    **Note:** Make sure the specified database exists or the script will fail.

## Setup

1.  **Save the script:** Save the provided code to a file, for example, `file_organizer.sh`.
2.  **Make it executable:** Open your terminal and navigate to the directory where you saved the file. Then, make the script executable using the command:
    ```bash
    chmod +x file_organizer.sh
    ```
3.  **Create MySQL configuration file:** Create a file named `.testdb.cnf` in your home directory (`$HOME/`). Add the necessary MySQL client configuration as described in the Prerequisites section, replacing the placeholders with your actual MySQL credentials and database name.
4.  **Ensure MySQL database and table:** Make sure the database specified in your `.testdb.cnf` file exists. When you run the script for the first time for organization, it will automatically create the `files` table if it doesn't exist.

## How to Use

1.  **Open your terminal.**
2.  **Navigate to the directory where you saved the `file_organizer.sh` script.**
3.  **Run the script:**
    ```bash
    ./file_organizer.sh
    ```
4.  **Follow the on-screen prompts:** The `dialog` menu will guide you through the organization or undo process.

## Organization Categories and Supported File Extensions

The script organizes files into the following categories based on their lowercase file extensions:

* **Images:** `jpg`, `jpeg`, `png`, `gif`
* **Documents:** `pdf`, `docx`, `txt`, `pptx`
* **Music:** `mp3`, `wav`
* **Videos:** `mp4`, `mkv`, `mov`
* **Archives:** `zip`, `tar`, `gz`, `rar`
* **Scripts:** `py`, `sh`, `js`

## Logging

The script logs the details of file movements during the organization process to the file `/tmp/file_organizer_log.txt`.

## Important Notes

* **Database Credentials:** Ensure your MySQL configuration file (`$HOME/.testdb.cnf`) contains the correct credentials. Incorrect credentials will prevent the script from functioning properly.
* **Database Existence:** The MySQL database specified in the configuration file must exist.
* **Error Handling:** The script includes basic error handling, such as checking for the `dialog` utility and valid directories.
* **File Overwriting:** The script assumes that there are no duplicate filenames within the destination folders. If there are, the moved file might overwrite the existing file with the same name.
* **Permissions:** Ensure the script has the necessary permissions to read and write files and directories in the target location.
* **Customization:** You can customize the categories and supported file extensions by modifying the `FILE_TYPES` associative array in the script.

This script provides a basic framework for file organization. You can further enhance it by adding more features, error handling, and customization options as needed.
