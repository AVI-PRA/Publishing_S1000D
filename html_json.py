import os
import json
from bs4 import BeautifulSoup
import sys
import tkinter as tk
from tkinter import filedialog, messagebox
import glob


class DataCollectorApp:
    def __init__(self, root):
        self.root = root
        self.root.title("HTML Data Extractor")

        # --- Variables ---
        self.html_folder_path = tk.StringVar(value="./CSDBB")
        self.output_js_file_path = tk.StringVar(value="./data_index.js")

        # --- UI Layout ---
        self.create_widgets()

    def create_widgets(self):
        main_frame = tk.Frame(self.root, padx=10, pady=10)
        main_frame.pack(fill=tk.BOTH, expand=True)

        # HTML Input Directory
        tk.Label(main_frame, text="HTML Input Folder:").grid(
            row=0, column=0, sticky="w", pady=2
        )
        tk.Entry(main_frame, textvariable=self.html_folder_path, width=50).grid(
            row=0, column=1, sticky="ew", padx=5
        )
        tk.Button(
            main_frame,
            text="Browse",
            command=lambda: self.browse_dir(self.html_folder_path),
        ).grid(row=0, column=2)

        # Output JS File
        tk.Label(main_frame, text="Output JavaScript File:").grid(
            row=1, column=0, sticky="w", pady=2
        )
        tk.Entry(main_frame, textvariable=self.output_js_file_path, width=50).grid(
            row=1, column=1, sticky="ew", padx=5
        )
        tk.Button(
            main_frame,
            text="Browse",
            command=lambda: self.browse_file(
                self.output_js_file_path, [("JavaScript Files", "*.js")]
            ),
        ).grid(row=1, column=2)

        # Transform Button
        transform_button = tk.Button(
            main_frame, text="Generate Data Source", command=self.run_processing
        )
        transform_button.grid(row=2, column=0, columnspan=3, pady=10)

        # Status and Log
        self.status_label = tk.Label(main_frame, text="Ready.", fg="blue")
        self.status_label.grid(row=3, column=0, columnspan=3, sticky="w", pady=5)

    def browse_dir(self, var):
        dirname = filedialog.askdirectory()
        if dirname:
            var.set(dirname)

    def browse_file(self, var, filetypes):
        filename = filedialog.asksaveasfilename(
            filetypes=filetypes, defaultextension=".js"
        )
        if filename:
            var.set(filename)

    def run_processing(self):
        self.status_label.config(text="Starting data collection...", fg="blue")
        self.root.update_idletasks()

        html_folder = self.html_folder_path.get()
        output_js_file = self.output_js_file_path.get()
        data_collection = []

        try:
            if not os.path.isdir(html_folder):
                raise FileNotFoundError(f"Input directory '{html_folder}' not found.")

            print(f"Scanning directory: {html_folder}")

            # Find all HTML files
            html_files = glob.glob(os.path.join(html_folder, "*.html"))

            if not html_files:
                messagebox.showwarning(
                    "Warning",
                    f"No HTML files found in '{html_folder}'. Output file will be empty.",
                )
                self.status_label.config(text="Finished (No files found).", fg="orange")
                self.write_js_file(data_collection, output_js_file)
                return

            for file_path in html_files:
                file_name = os.path.basename(file_path)
                base_name = os.path.splitext(file_name)[0]

                last_underscore_index = base_name.rfind("_")
                dmc_id = (
                    base_name[:last_underscore_index]
                    if last_underscore_index != -1
                    else base_name
                )

                self.status_label.config(
                    text=f"Processing: {file_name} -> ID: {dmc_id}"
                )
                self.root.update_idletasks()

                try:
                    with open(
                        file_path, "r", encoding="utf-8", errors="ignore"
                    ) as f_html:
                        html_content_string = f_html.read()

                    soup = BeautifulSoup(html_content_string, "lxml")

                    page_title = ""
                    title_tag = soup.find("title")
                    if title_tag and title_tag.string:
                        page_title = title_tag.string.strip()

                    inner_content = ""
                    body_tag = soup.find("body")
                    if body_tag:
                        inner_content = "".join(
                            str(c) for c in body_tag.contents
                        ).strip()

                    data_entry = {
                        "id": dmc_id,
                        "title": page_title,
                        "type": "data_module",
                        "data": inner_content,
                    }
                    data_collection.append(data_entry)

                except Exception as e:
                    print(f"Error processing file {file_name}: {e}")
                    # Continue to the next file on error
                    continue

            self.write_js_file(data_collection, output_js_file)
            messagebox.showinfo(
                "Success",
                f"Successfully processed {len(data_collection)} files and created the data source.",
            )
            self.status_label.config(text="Finished.", fg="green")

        except FileNotFoundError as e:
            messagebox.showerror("Error", str(e))
            self.status_label.config(text="Error occurred.", fg="red")
        except Exception as e:
            messagebox.showerror("Error", f"An unexpected error occurred: {e}")
            self.status_label.config(text="Error occurred.", fg="red")

    def write_js_file(self, data, file_path):
        """Writes the collected data to a JavaScript file."""
        try:
            json_string = json.dumps(data, indent=2)
            with open(file_path, "w", encoding="utf-8") as f_out:
                f_out.write("const htmlDataSource = ")
                f_out.write(json_string)
                f_out.write(";\n\n")
                f_out.write("module.exports = htmlDataSource;\n")
        except Exception as e:
            print(f"Error writing output file {file_path}: {e}")
            raise


if __name__ == "__main__":
    root = tk.Tk()
    app = DataCollectorApp(root)
    root.mainloop()
