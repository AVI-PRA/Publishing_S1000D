import argparse
import os
import sys
import re # Import the regular expression module

# --- Configuration ---
# You can add or remove tag names from this list as needed.
TAGS_TO_UNESCAPE = [
    'internalRef', 'symbol', 'emphasis', 'verbatimText',
    'dmRef', 'pmRef', 'externalPubRef', 'changeInline',
    'superScript', 'subScript', 'para' # Added para as it can sometimes be escaped
]
# -------------------

def clean_xml_content(content: str, filename: str) -> str:
    """
    Cleans the XML content by fixing double-escaped entities and un-escaping
    specific S1000D tags using regular expressions for robustness.
    """
    # --- Step 1: Fix Double Escaping ---
    # This is still the most critical first step. It fixes &amp;amp;, &amp;#43;, etc.
    if '&amp;' in content:
        print("   - Fixing double-escaped entities...")
        content = content.replace('&amp;', '&')

    # --- Step 2: Use Regex to Fix Broken Tags (The NEW, ROBUST METHOD) ---
    # Create a regex pattern from our list of tags.
    # This will look like '(internalRef|symbol|emphasis|...)'
    tag_pattern = '|'.join(TAGS_TO_UNESCAPE)

    # This regex finds tags that have been fully escaped, like:
    # &lt;internalRef internalRefId="Fig-1"&gt;...&lt;/internalRef&gt;
    # It captures the tag name, its attributes, and its content.
    # It then rebuilds the tag correctly.
    #
    # Breakdown of the regex:
    # &lt;({tag_pattern})   # Matches '&lt;' and captures the tag name (group 1)
    # ([^&]*)?             # Optionally captures attributes (group 2)
    # &gt;                  # Matches the broken '&gt;'
    # (.*?)                # Captures the inner content lazily (group 3)
    # &lt;\/\1&gt;          # Matches the closing tag (e.g., '&lt;/internalRef&gt;')
    
    regex = re.compile(f'&lt;({tag_pattern})([^&]*)&gt;(.*?)&lt;/\\1&gt;', re.DOTALL)
    
    # The replacement function rebuilds the tag correctly
    def replace_tag(match):
        tag_name = match.group(1)
        attributes = match.group(2)
        inner_content = match.group(3)
        # Recursively clean the inner content as well! This handles nested broken tags.
        cleaned_inner = clean_xml_content(inner_content, filename)
        return f'<{tag_name}{attributes}>{cleaned_inner}</{tag_name}>'

    cleaned_content = regex.sub(replace_tag, content)

    # --- Step 3: Fix Self-Closing or Standalone Opening Tags ---
    # This regex specifically fixes the error you found, like:
    # <internalRef internalRefId="Fig-1"&gt;  (where the opening < is already fixed)
    # OR
    # &lt;symbol infoEntityIdent="..." /&gt; (a self-closing tag)
    
    regex_opening = re.compile(f'&lt;({tag_pattern})([^&]*)&gt;')
    cleaned_content = regex_opening.sub(r'<\1\2>', cleaned_content)

    print(f"   - Scanned and fixed broken XML tags.")
        
    return cleaned_content

def process_folder(input_dir: str, output_dir: str):
    """
    Finds all XML files in the input directory, cleans them, and saves them
    to the output directory, preserving the folder structure.
    """
    print("-" * 50)
    print(f"Input folder:  {os.path.abspath(input_dir)}")
    print(f"Output folder: {os.path.abspath(output_dir)}")
    print("-" * 50)

    files_processed = 0
    files_failed = 0

    for root, _, files in os.walk(input_dir):
        for file in files:
            if file.lower().endswith('.xml'):
                input_path = os.path.join(root, file)
                relative_path = os.path.relpath(input_path, input_dir)
                output_path = os.path.join(output_dir, relative_path)
                
                print(f"\nProcessing: {relative_path}")

                try:
                    output_sub_dir = os.path.dirname(output_path)
                    os.makedirs(output_sub_dir, exist_ok=True)

                    with open(input_path, 'r', encoding='utf-8') as f_in:
                        original_content = f_in.read()

                    cleaned_content = clean_xml_content(original_content, file)

                    with open(output_path, 'w', encoding='utf-8') as f_out:
                        f_out.write(cleaned_content)
                    
                    files_processed += 1
                except Exception as e:
                    print(f"   *** ERROR: Failed to process file '{file}'. Reason: {e}")
                    files_failed += 1

    print("-" * 50)
    print("Batch process complete.")
    print(f"Successfully processed: {files_processed} file(s).")
    if files_failed > 0:
        print(f"Failed to process:      {files_failed} file(s).")
    print("-" * 50)

def main():
    """Main function to handle command-line arguments."""
    parser = argparse.ArgumentParser(
        description="A batch-processing script to clean S1000D XML files in a folder.",
        epilog="Example: python batch_clean_s1000d.py ./my_xml_source ./my_cleaned_output"
    )
    parser.add_argument("input_folder", help="The path to the source folder containing XML files.")
    parser.add_argument("output_folder", help="The path to the destination folder where cleaned files will be saved.")
    
    args = parser.parse_args()

    if not os.path.isdir(args.input_folder):
        print(f"Error: Input folder not found at '{args.input_folder}'")
        sys.exit(1)
        
    if os.path.abspath(args.input_folder) == os.path.abspath(args.output_folder):
        print("Error: Input and output folders cannot be the same. Please specify a different output folder.")
        sys.exit(1)

    process_folder(args.input_folder, args.output_folder)

if __name__ == "__main__":
    main()