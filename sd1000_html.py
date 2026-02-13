import os
import subprocess
import glob
import tkinter as tk
from tkinter import filedialog, messagebox
import sys


class SaxonTransformerApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Saxon XSLT Transformer")

        # --- Configuration (Default Values) ---
        if getattr(sys, "frozen", False):
            # Running in a bundled executable
            base_path = sys._MEIPASS
        else:
            # Running in a normal Python environment
            base_path = os.path.dirname(os.path.abspath(__file__))

        self.saxon_jar = os.path.join(base_path, "saxon9he.jar")
        self.xsl_stylesheet = os.path.join(base_path, "demo3-1.xsl")
        self.graphic_path_prefix = "figures/"

        # --- Variables (User-configurable) ---
        self.input_dir_path = tk.StringVar(value="csdb")
        self.output_dir_path = tk.StringVar(value="CSDBB")

        # --- UI Layout ---
        self.create_widgets()

    def create_widgets(self):
        main_frame = tk.Frame(self.root, padx=10, pady=10)
        main_frame.pack(fill=tk.BOTH, expand=True)

        # Input Directory
        tk.Label(main_frame, text="Input Directory:").grid(
            row=0, column=0, sticky="w", pady=2
        )
        tk.Entry(main_frame, textvariable=self.input_dir_path, width=50).grid(
            row=0, column=1, sticky="ew", padx=5
        )
        tk.Button(
            main_frame,
            text="Browse",
            command=lambda: self.browse_dir(self.input_dir_path),
        ).grid(row=0, column=2)

        # Output Directory
        tk.Label(main_frame, text="Output Directory:").grid(
            row=1, column=0, sticky="w", pady=2
        )
        tk.Entry(main_frame, textvariable=self.output_dir_path, width=50).grid(
            row=1, column=1, sticky="ew", padx=5
        )
        tk.Button(
            main_frame,
            text="Browse",
            command=lambda: self.browse_dir(self.output_dir_path),
        ).grid(row=1, column=2)

        # Transform Button
        transform_button = tk.Button(
            main_frame, text="Run Transformations", command=self.run_transformations
        )
        transform_button.grid(row=2, column=0, columnspan=3, pady=10)

        # Status Label
        self.status_label = tk.Label(main_frame, text="Ready.", fg="blue")
        self.status_label.grid(row=3, column=0, columnspan=3, sticky="w", pady=5)

    def browse_dir(self, var):
        dirname = filedialog.askdirectory()
        if dirname:
            var.set(dirname)

    def run_transformations(self):
        self.status_label.config(text="Starting transformations...", fg="blue")
        self.root.update_idletasks()

        input_dir = self.input_dir_path.get()
        output_dir = self.output_dir_path.get()

        try:
            # Validate paths and ensure default files exist
            if not os.path.exists(self.saxon_jar):
                raise FileNotFoundError(
                    f"Error: Saxon JAR not found at '{self.saxon_jar}'"
                )
            if not os.path.exists(self.xsl_stylesheet):
                raise FileNotFoundError(
                    f"Error: XSLT stylesheet not found at '{self.xsl_stylesheet}'"
                )
            if not os.path.isdir(input_dir):
                raise FileNotFoundError(
                    f"Error: Input directory not found at '{input_dir}'"
                )

            os.makedirs(output_dir, exist_ok=True)

            xml_files = glob.glob(os.path.join(input_dir, "DMC-*.XML"))

            if not xml_files:
                messagebox.showwarning(
                    "Warning",
                    f"No XML files matching 'DMC-*.XML' found in '{input_dir}'.",
                )
                self.status_label.config(text="Finished (No files found).", fg="orange")
                return

            for xml_file in xml_files:
                self.status_label.config(
                    text=f"Processing '{os.path.basename(xml_file)}'..."
                )
                self.root.update_idletasks()

                base_name = os.path.splitext(os.path.basename(xml_file))[0]
                html_file_name = f"{base_name}.html"
                html_file_path = os.path.join(output_dir, html_file_name)

                saxon_args = [
                    "java",
                    "-jar",
                    self.saxon_jar,
                    f"-s:{xml_file}",
                    f"-xsl:{self.xsl_stylesheet}",
                    f"-o:{html_file_path}",
                    "outputFormat=html",
                    f"graphicPathPrefix={self.graphic_path_prefix}",
                ]

                try:
                    subprocess.run(
                        saxon_args, check=True, capture_output=True, text=True
                    )
                except subprocess.CalledProcessError as e:
                    messagebox.showerror(
                        "Saxon Error",
                        f"Failed to execute Saxon for '{os.path.basename(xml_file)}':\n\n{e.stderr}",
                    )
                    self.status_label.config(text="Error occurred.", fg="red")
                    return
                except FileNotFoundError:
                    messagebox.showerror(
                        "Execution Error",
                        "The 'java' command was not found. Ensure Java is installed and in your system's PATH.",
                    )
                    self.status_label.config(text="Error occurred.", fg="red")
                    return

            messagebox.showinfo(
                "Success", "All transformations completed successfully!"
            )
            self.status_label.config(text="Finished.", fg="green")

        except Exception as e:
            messagebox.showerror("Error", f"An error occurred: {e}")
            self.status_label.config(text="Error occurred.", fg="red")


if __name__ == "__main__":
    root = tk.Tk()
    app = SaxonTransformerApp(root)
    root.mainloop()
