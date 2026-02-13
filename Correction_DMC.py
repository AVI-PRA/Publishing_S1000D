import os
import re

# Folder containing your files
folder_path = r"csdb"

# Regex pattern to match and remove the unwanted hyphen
# Looks for "-56-" followed by any two digits, then a hyphen, then a letter/number
# The goal is to remove the hyphen after the two digits but before the letter/number
pattern = re.compile(r"(-02-\d{2})-([A-Za-z0-9])")

for filename in os.listdir(folder_path):
    old_path = os.path.join(folder_path, filename)

    if os.path.isfile(old_path):
        # Apply the fix
        new_filename = pattern.sub(r"\1\2", filename)
        new_path = os.path.join(folder_path, new_filename)

        if new_filename != filename:  # Only rename if changed
            os.rename(old_path, new_path)
            print(f"Renamed: {filename} -> {new_filename}")


# import os
# import re

# # Folder containing your files
# folder_path = r"csdb"

# # Regex pattern to match and remove the unwanted hyphen
# # Looks for "-01-01-" followed by a letter (e.g., -A-)
# pattern = re.compile(r"(-74-01)-([A-Za-z0-9])")

# for filename in os.listdir(folder_path):
#     old_path = os.path.join(folder_path, filename)

#     if os.path.isfile(old_path):
#         # Apply the fix
#         new_filename = pattern.sub(r"\1\2", filename)
#         new_path = os.path.join(folder_path, new_filename)

#         if new_filename != filename:  # Only rename if changed
#             os.rename(old_path, new_path)
#             print(f"Renamed: {filename} -> {new_filename}")
