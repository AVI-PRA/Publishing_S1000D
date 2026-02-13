import re
import os
import tkinter as tk
from tkinter import filedialog, messagebox, scrolledtext

# -------------------------------------------------
# Core Logic
# -------------------------------------------------


def fix_single_file(input_file, output_file):
    with open(input_file, "r", encoding="utf-8") as f:
        text = f.read()

    anchor_pattern = re.compile(r"\[\[(Figure-\d+|Table-\d+)\]\]\s*\n\.(.+)")

    id_to_title = {}
    for match in anchor_pattern.finditer(text):
        id_to_title[match.group(1)] = match.group(2).strip()

    def replace_ref(match):
        ref_id = match.group(1)
        title = id_to_title.get(ref_id)
        if title:
            return f"<<{ref_id} , {title}>>"
        return match.group(0)

    ref_pattern = re.compile(r"<<\s*(Figure-\d+|Table-\d+)\s*>>")
    return ref_pattern.sub(replace_ref, text)


def process_folder(input_dir, output_dir, log):
    for root, dirs, files in os.walk(input_dir):
        for name in files:
            if name.lower().endswith(".adoc"):
                in_file = os.path.join(root, name)

                rel_path = os.path.relpath(root, input_dir)
                out_folder = os.path.join(output_dir, rel_path)
                os.makedirs(out_folder, exist_ok=True)

                out_file = os.path.join(out_folder, name)

                fixed_text = fix_single_file(in_file, out_file)

                with open(out_file, "w", encoding="utf-8") as f:
                    f.write(fixed_text)

                log.insert(tk.END, f"Fixed: {in_file}\n")
                log.see(tk.END)

    messagebox.showinfo("Done", "All ADOC files processed successfully!")


# -------------------------------------------------
# GUI
# -------------------------------------------------


def browse_input():
    path = filedialog.askdirectory()
    if path:
        input_entry.delete(0, tk.END)
        input_entry.insert(0, path)


def browse_output():
    path = filedialog.askdirectory()
    if path:
        output_entry.delete(0, tk.END)
        output_entry.insert(0, path)


def run_tool():
    inp = input_entry.get()
    out = output_entry.get()

    if not inp or not out:
        messagebox.showerror("Error", "Please select both input and output folders.")
        return

    log_area.delete(1.0, tk.END)
    process_folder(inp, out, log_area)


# -------------------------------------------------
# Window Layout
# -------------------------------------------------

root = tk.Tk()
root.title("ADOC Figure/Table Reference Fixer")
root.geometry("650x450")

tk.Label(root, text="Input ADOC Folder:").pack(anchor="w", padx=10, pady=(10, 0))
input_entry = tk.Entry(root, width=70)
input_entry.pack(padx=10)
tk.Button(root, text="Browse", command=browse_input).pack(padx=10, pady=5)

tk.Label(root, text="Output Folder:").pack(anchor="w", padx=10, pady=(10, 0))
output_entry = tk.Entry(root, width=70)
output_entry.pack(padx=10)
tk.Button(root, text="Browse", command=browse_output).pack(padx=10, pady=5)

tk.Button(
    root, text="RUN", command=run_tool, bg="#4CAF50", fg="white", width=20, height=2
).pack(pady=15)

log_area = scrolledtext.ScrolledText(root, width=80, height=12)
log_area.pack(padx=10, pady=10)

root.mainloop()
