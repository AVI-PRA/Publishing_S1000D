# import os
# import re

# folder_path = r"D:/chatbot/example"

# pattern = re.compile(r"^(DMC-)([A-Z0-9]+)(P\d+[A-Z]?)-(.*)$", re.IGNORECASE)

# for filename in os.listdir(folder_path):
#     match = pattern.match(filename)
#     if match:
#         dmc_part = match.group(1)
#         dynamic_part = match.group(2)
#         p15b_part = match.group(3)
#         rest_part = match.group(4)

#         new_filename = f"{dmc_part}{p15b_part}{dynamic_part}-{rest_part}"

#         old_path = os.path.join(folder_path, filename)
#         new_path = os.path.join(folder_path, new_filename)

#         os.rename(old_path, new_path)
#         print(f"Renamed: {filename} -> {new_filename}")


import os
import re

folder_path = r"csdb"

# Match: DMC- <anything> P15B - rest
pattern = re.compile(r"^(DMC-)(?:[A-Z0-9]+)(P\d+[A-Z]?)-(.*)$", re.IGNORECASE)

for filename in os.listdir(folder_path):
    match = pattern.match(filename)
    if match:
        dmc_part = match.group(1)  # DMC-
        p15b_part = match.group(2)  # P15B
        rest_part = match.group(3)  # rest of filename

        new_filename = f"{dmc_part}{p15b_part}-{rest_part}"

        old_path = os.path.join(folder_path, filename)
        new_path = os.path.join(folder_path, new_filename)

        os.rename(old_path, new_path)
        print(f"Renamed: {filename} -> {new_filename}")




