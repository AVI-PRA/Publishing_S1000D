import re

input_file = r"c:\Users\IETM\Downloads\Stysheets\toc.js"
output_file = r"c:\Users\IETM\Downloads\Stysheets\toc_updated.js"

# DMC pattern
dmc_regex = r"[A-Z]{3}-[A-Z]-[A-Z0-9]{3}-\d{2}-\d{2}-\d{2}[A-Z]-\d{3}[A-Z]-[A-Z]"

with open(input_file, "r", encoding="utf-8") as f:
    lines = f.readlines()

new_lines = []
current_dmc = None

for line in lines:

    # Detect DisplayName line
    if '"DisplayName"' in line:
        # Extract full value
        m = re.search(r'"DisplayName"\s*:\s*"(.*)"', line)
        if m:
            full = m.group(1)

            # Extract DMC
            dmc_match = re.match(dmc_regex, full)
            if dmc_match:
                current_dmc = dmc_match.group(0)
                rest = full[len(current_dmc):].strip()

                # Fix DisplayName (remove DMC)
                line = f'    "DisplayName": "{rest}",\n'

    # Fix ID line only if previous DisplayName had a DMC
    if '"ID"' in line and current_dmc:
        line = f'    "ID": "{current_dmc}",\n'
        current_dmc = None  # reset

    new_lines.append(line)

with open(output_file, "w", encoding="utf-8") as f:
    f.writelines(new_lines)

print("DONE — File updated successfully!")
