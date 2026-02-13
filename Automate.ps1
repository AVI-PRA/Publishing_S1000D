# --- Configuration ---
$saxonJar = "saxon9he.jar"
$xslStylesheet = "ciws.xsl"
$inputDir = "csdb"
$outputDir = "CSDBB" # Outputting to the same directory
$xmlFilter = "DMC-*.XML"
$graphicPathPrefix = "figures/" # Your XSLT parameter
# --- End Configuration ---

# Get full paths for checks



$saxonJarPath = Resolve-Path $saxonJar -ErrorAction SilentlyContinue
$xslStylesheetPath = Resolve-Path $xslStylesheet -ErrorAction SilentlyContinue
$inputDirPath = Resolve-Path $inputDir -ErrorAction SilentlyContinue

# Check if Saxon JAR exists
if (-not $saxonJarPath) {
    Write-Error "Error: Saxon JAR not found at '$saxonJar'"
    exit 1
}

# Check if Stylesheet exists
if (-not $xslStylesheetPath) {
    Write-Error "Error: XSLT stylesheet not found at '$xslStylesheet'"
    exit 1
}

# Check if Input directory exists
if (-not ($inputDirPath -and (Get-Item $inputDirPath).PSIsContainer)) {
    Write-Error "Error: Input directory not found at '$inputDir'"
    exit 1
}

# Ensure output directory exists (optional)
# if (-not (Test-Path $outputDir)) { New-Item -ItemType Directory -Path $outputDir -Force }

Write-Host "Starting transformations..."

# Get XML files
$xmlFiles = Get-ChildItem -Path $inputDir -Filter $xmlFilter

if ($xmlFiles.Count -eq 0) {
    Write-Warning "No XML files matching '$xmlFilter' found in '$inputDir'."
    exit 0
}

foreach ($xmlFile in $xmlFiles) {
    $htmlFileName = "$($xmlFile.BaseName).html"
    $htmlFilePath = Join-Path -Path $outputDir -ChildPath $htmlFileName

    Write-Host "Processing '$($xmlFile.FullName)' -> '$htmlFilePath'"

    # Construct arguments carefully for PowerShell
    $saxonArgs = @(
        "-jar", $saxonJarPath.Path,
        "-s:$($xmlFile.FullName)",
        "-xsl:$($xslStylesheetPath.Path)",
        "-o:$htmlFilePath",
        "outputFormat=html",
        "graphicPathPrefix=$graphicPathPrefix"

    )

    # Run Saxon
    try {
        # Using Start-Process can sometimes handle complex arguments better,
        # but direct call usually works for java. Add -Wait if using Start-Process.
        # Start-Process java -ArgumentList $saxonArgs -Wait -NoNewWindow
        java @saxonArgs 

        if ($LASTEXITCODE -ne 0) {
             Write-Error "Error processing '$($xmlFile.Name)'. Saxon exited with code $LASTEXITCODE."
             # To stop on error, uncomment the next line
             # exit $LASTEXITCODE
        }
    } catch {
        Write-Error "Failed to execute Saxon for '$($xmlFile.Name)': $_"
        # To stop on error, uncomment the next line
        # exit 1
    }
}

Write-Host "Finished."


# java -jar saxon9he.jar -s:Toc.xml -xsl:pm_toc.xsl -o:output_toc2.js