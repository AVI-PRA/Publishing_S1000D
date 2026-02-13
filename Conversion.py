import tkinter as tk
from tkinter import filedialog, messagebox, scrolledtext
import subprocess
import os
import threading

# --- Application Configuration ---
# Use relative paths based on the project structure
SCRIPTS_DIR = "scripts"
ASSETS_DIR = "assets"
POWERSHELL_SCRIPT = os.path.join(SCRIPTS_DIR, "Automate.ps1")
PYTHON_SCRIPT = os.path.join(SCRIPTS_DIR, "html_json.py")
XSL_FILE = os.path.join(ASSETS_DIR, "demo3.xsl")
SAXON_JAR = os.path.join(ASSETS_DIR, "saxon9he.jar")


# --- Main Application Class ---
class ConverterApp:
    def __init__(self, root):
        self.root = root
        self.root.title("S1000D to JS Converter")
        self.root.geometry("700x500")

        main_frame = tk.Frame(root, padx=15, pady=15)
        main_frame.pack(fill=tk.BOTH, expand=True)

        # --- Folder Selection ---
        self.input_dir_entry = self.create_folder_selection(
            main_frame, "Input S1000D XML Folder:", 0
        )
        self.output_dir_entry = self.create_folder_selection(
            main_frame, "Output Folder:", 2
        )

        # --- Conversion Button ---
        self.convert_button = tk.Button(
            main_frame,
            text="Start Conversion",
            command=self.start_conversion_thread,
            bg="#4CAF50",
            fg="white",
            font=("Arial", 12, "bold"),
        )
        self.convert_button.grid(row=4, column=0, columnspan=2, pady=20, sticky="ew")

        # --- Status Log ---
        log_label = tk.Label(main_frame, text="Log:", font=("Arial", 10, "bold"))
        log_label.grid(row=5, column=0, sticky="w")
        self.log_widget = scrolledtext.ScrolledText(
            main_frame, height=15, state="disabled", wrap=tk.WORD, bg="#f0f0f0"
        )
        self.log_widget.grid(row=6, column=0, columnspan=2, sticky="nsew")

        main_frame.columnconfigure(0, weight=1)
        main_frame.rowconfigure(6, weight=1)

    def create_folder_selection(self, parent, label_text, row):
        label = tk.Label(parent, text=label_text, anchor="w")
        label.grid(row=row, column=0, sticky="w", pady=(10, 2))

        entry = tk.Entry(parent, width=60)
        entry.grid(row=row + 1, column=0, sticky="ew")

        button = tk.Button(
            parent, text="Browse...", command=lambda: self.browse_folder(entry)
        )
        button.grid(row=row + 1, column=1, padx=(5, 0))
        return entry

    def browse_folder(self, entry_widget):
        directory = filedialog.askdirectory()
        if directory:
            entry_widget.delete(0, tk.END)
            entry_widget.insert(0, directory)

    def log(self, message):
        self.log_widget.config(state="normal")
        self.log_widget.insert(tk.END, message + "\n")
        self.log_widget.see(tk.END)
        self.log_widget.config(state="disabled")
        self.root.update_idletasks()

    def start_conversion_thread(self):
        self.convert_button.config(state="disabled", text="Processing...")
        thread = threading.Thread(target=self.run_conversion)
        thread.start()

    def run_conversion(self):
        input_dir = self.input_dir_entry.get()
        output_dir = self.output_dir_entry.get()

        if not all([input_dir, output_dir]):
            messagebox.showerror(
                "Error", "Please select both input and output folders."
            )
            self.reset_button_state()
            return

        html_output_dir = os.path.join(output_dir, "html")
        os.makedirs(html_output_dir, exist_ok=True)
        final_js_file = os.path.join(output_dir, "dataIndex.js")

        try:
            # Step 1: Run PowerShell script
            self.log("--- Step 1: Converting S1000D XML to HTML ---")
            ps_command = [
                "powershell.exe",
                "-ExecutionPolicy",
                "Bypass",
                "-File",
                POWERSHELL_SCRIPT,
                "-saxonJar",
                SAXON_JAR,
                "-xslStylesheet",
                XSL_FILE,
                "-inputDir",
                input_dir,
                "-outputDir",
                html_output_dir,
            ]
            self.run_subprocess(ps_command)
            self.log(">>> HTML conversion successful.\n")

            # Step 2: Run Python script
            self.log("--- Step 2: Converting HTML to dataIndex.js ---")
            py_command = ["python", PYTHON_SCRIPT, html_output_dir, final_js_file]
            self.run_subprocess(py_command)
            self.log(">>> JavaScript data index created successfully.")
            self.log("\n--- Conversion Finished! ---")
            messagebox.showinfo(
                "Success", f"Conversion completed!\nOutput saved to: {output_dir}"
            )

        except Exception as e:
            self.log(f"An error occurred: {e}")
            messagebox.showerror(
                "Error",
                f"An error occurred during the process. Check the log for details.",
            )

        finally:
            self.reset_button_state()

    def run_subprocess(self, command):
        process = subprocess.Popen(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            encoding="utf-8",
        )
        while True:
            output = process.stdout.readline()
            if output == "" and process.poll() is not None:
                break
            if output:
                self.log(output.strip())

        stderr = process.communicate()[1]
        if process.returncode != 0:
            self.log(f"ERROR: {stderr}")
            raise subprocess.CalledProcessError(
                process.returncode, command, output=process.stdout, stderr=stderr
            )

    def reset_button_state(self):
        self.convert_button.config(state="normal", text="Start Conversion")


if __name__ == "__main__":
    root = tk.Tk()
    app = ConverterApp(root)
    root.mainloop()
