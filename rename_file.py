import os
import re
import tkinter as tk
from tkinter import filedialog


def rename_s1000d_files_to_base_dmc(target_folder):
    """
    Scans a directory for S1000D files and renames them to their base DMC,
    removing all suffix information (issue, in-work, language, etc.) while
    preserving the original file extension.

    For example:
    'DMC-GSV-A-L0-00-16-00A-140A-D_001-00_EN-IN.html'
    will be renamed to:
    'DMC-GSV-A-L0-00-16-00A-140A-D.html'

    Args:
        target_folder (str): The absolute path to the folder to process.
    """
    if not os.path.isdir(target_folder):
        print(f"Error: The specified folder does not exist:\n{target_folder}")
        return

    print(f"Scanning folder: {target_folder}\n")

    # --- KEY CHANGE IS HERE ---
    # This new regex is simpler and more effective for your goal.
    # It captures two main parts:
    # 1. The base DMC: Starts with 'DMC-' and captures everything up to the first underscore.
    # 2. The extension: Captures the file extension (e.g., '.html', '.xml').
    # The '.*' in the middle matches the entire suffix you want to discard.
    dmc_pattern = re.compile(
        r"^(?P<base_dmc>DMC-.*?)"  # Part 1: The base DMC (non-greedy)
        r"_"  # A literal underscore that marks the start of the suffix
        r".*?"  # The rest of the filename (the part to discard)
        r"(?P<extension>\.\w+)$",  # Part 2: The file extension
        re.IGNORECASE,
    )  # Ignore case for .xml vs .XML, etc.

    rename_count = 0
    skipped_count = 0

    # Iterate over every file in the directory
    for filename in os.listdir(target_folder):
        match = dmc_pattern.match(filename)

        # If the filename matches our pattern (is a DMC with a suffix)
        if match:
            # Construct the new filename from the captured base DMC and extension
            new_filename = f"{match.group('base_dmc')}{match.group('extension')}"

            # Get the full old and new file paths
            old_filepath = os.path.join(target_folder, filename)
            new_filepath = os.path.join(target_folder, new_filename)

            try:
                # Check if a file with the new name already exists to prevent errors
                if os.path.exists(new_filepath):
                    print(
                        f"SKIPPED: '{filename}' -> A file named '{new_filename}' already exists."
                    )
                    skipped_count += 1
                else:
                    # Perform the rename
                    os.rename(old_filepath, new_filepath)
                    print(f"RENAMED: '{filename}' -> '{new_filename}'")
                    rename_count += 1
            except OSError as e:
                print(f"ERROR: Could not rename '{filename}'. Reason: {e}")
                skipped_count += 1
        else:
            # If the filename does not match, we don't do anything
            skipped_count += 1

    print("\n--- Summary ---")
    print(f"Successfully renamed {rename_count} file(s).")
    print(f"Skipped {skipped_count} file(s) (no suffix to remove, errors, etc.).")
    print("-----------------")


if __name__ == "__main__":
    # --- Main execution block ---
    # This part is unchanged. It will still pop up a window to ask for the folder.
    root = tk.Tk()
    root.withdraw()

    print("Please select the folder containing your S1000D files to rename.")
    folder_path = filedialog.askdirectory(title="Select Folder to Rename Files")

    if folder_path:
        rename_s1000d_files_to_base_dmc(folder_path)
    else:
        print("No folder selected. Exiting script.")
