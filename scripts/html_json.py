import os
import json
from bs4 import BeautifulSoup
import sys 

html_folder = './CSDBB'      
output_js_file = './dataIndex.js' 



data_collection = []

if not os.path.isdir(html_folder):
    print(f"Error: Input directory '{html_folder}' not found.")
    sys.exit(1)

print(f"Scanning directory: {html_folder}")

# Use scandir for potentially better performance on many files
for entry in os.scandir(html_folder):
    # Process only files ending with .html (case-insensitive)
    if entry.is_file() and entry.name.lower().endswith('.html'):
       
        base_name = os.path.splitext(entry.name)[0]

        # Find the last underscore (which separates DMC from lang/country)
        last_underscore_index = base_name.rfind('_')

        if last_underscore_index != -1:
            dmc_id = base_name[:last_underscore_index]
        else:
            dmc_id = base_name 

        html_filepath = entry.path
        print(f"Processing: {entry.name} -> ID: {dmc_id}") 
        html_filepath = entry.path
        print(f"Processing: {entry.name} -> ID: {dmc_id}")

        try:
          
            html_content_string = ""
            try:
                with open(html_filepath, 'r', encoding='utf-8') as f_html:
                    html_content_string = f_html.read()
            except UnicodeDecodeError:
                print(f"Warning: UTF-8 decoding failed for {entry.name}. Trying 'latin-1'.")
                try:
                     with open(html_filepath, 'r', encoding='latin-1') as f_html:
                         html_content_string = f_html.read()
                except Exception as enc_err:
                     print(f"Error reading file {entry.name} with multiple encodings: {enc_err}")
                     continue 

            
            soup = BeautifulSoup(html_content_string, 'lxml')

           
            page_title = "" 
            title_tag = soup.find('title')
            if title_tag and title_tag.string:
                 page_title = title_tag.string.strip()

          
            inner_content = "" 
            body_tag = soup.find('body')
            if body_tag:
               
                inner_content = "".join(str(c) for c in body_tag.contents).strip()
            else:
                 print(f"Warning: No <body> tag found in {entry.name}. Content will be empty.")
                

       
            data_entry = {
                "id": dmc_id,
                "title": page_title,   
                "Data": inner_content
            }
            data_collection.append(data_entry)

        except Exception as e:
            print(f"Error processing file {entry.name}: {e}")
            # Optionally append an entry with an error message or skip
            # data_collection.append({"id": dmc_id, "title": f"Error processing: {e}", "content": "", "error": True})


if not data_collection:
    print("No HTML files processed or found. Output file will contain an empty array.")
 
    data_collection = []


print(f"\nProcessed {len(data_collection)} HTML files.")
print(f"Writing combined data to: {output_js_file}")

try:
  
    json_string = json.dumps(data_collection, indent=2)


    with open(output_js_file, 'w', encoding='utf-8') as f_out:
        f_out.write("const htmlDataSource = ")
        f_out.write(json_string)
        f_out.write(";\n\n") 
        f_out.write("module.exports = htmlDataSource;\n")

    print("Successfully created JavaScript data source file.")

except Exception as e:
    print(f"Error writing output file {output_js_file}: {e}")