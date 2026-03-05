# --- Configuration ---
$saxonJar = "saxon9he.jar"
$xslStylesheet = "demo-5.xsl"
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

# Initialize tracking arrays
$successfulFiles = @()
$failedFiles = @()
$totalFiles = $xmlFiles.Count

Write-Host "Found $totalFiles XML files to process."
Write-Host ""

foreach ($xmlFile in $xmlFiles) {
    $htmlFileName = "$($xmlFile.BaseName).html"
    $htmlFilePath = Join-Path -Path $outputDir -ChildPath $htmlFileName

    Write-Host "Processing '$($xmlFile.Name)'..."

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
    $transformFailed = $false
    try {
        # Using Start-Process can sometimes handle complex arguments better,
        # but direct call usually works for java. Add -Wait if using Start-Process.
        # Start-Process java -ArgumentList $saxonArgs -Wait -NoNewWindow
        java @saxonArgs 

        if ($LASTEXITCODE -ne 0) {
             Write-Host "  [FAILED] Saxon exited with code $LASTEXITCODE" -ForegroundColor Red
             $transformFailed = $true
             $failedFiles += [PSCustomObject]@{
                FileName = $xmlFile.Name
                Reason = "Saxon exit code: $LASTEXITCODE"
             }
        } elseif (-not (Test-Path $htmlFilePath)) {
             Write-Host "  [FAILED] Output file not created" -ForegroundColor Red
             $transformFailed = $true
             $failedFiles += [PSCustomObject]@{
                FileName = $xmlFile.Name
                Reason = "Output file not created"
             }
        } else {
             Write-Host "  [SUCCESS]" -ForegroundColor Green
             $successfulFiles += $xmlFile.Name
        }
    } catch {
        Write-Host "  [FAILED] Exception: $_" -ForegroundColor Red
        $transformFailed = $true
        $failedFiles += [PSCustomObject]@{
            FileName = $xmlFile.Name
            Reason = "Exception: $_"
        }
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TRANSFORMATION SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Total Files:      $totalFiles"
Write-Host "Successful:       $($successfulFiles.Count)" -ForegroundColor Green
Write-Host "Failed:           $($failedFiles.Count)" -ForegroundColor $(if ($failedFiles.Count -gt 0) { "Red" } else { "Green" })
Write-Host ""

if ($failedFiles.Count -gt 0) {
    Write-Host "FAILED FILES:" -ForegroundColor Red
    Write-Host "----------------------------------------"
    foreach ($failed in $failedFiles) {
        Write-Host "  - $($failed.FileName)" -ForegroundColor Yellow
        Write-Host "    Reason: $($failed.Reason)" -ForegroundColor Gray
    }
    Write-Host ""
    
    # Save failed files to a log
    $logFile = "transformation_errors.log"
    $logContent = "Transformation Errors - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`r`n"
    $logContent += "=" * 60 + "`r`n"
    $logContent += "Total Files: $totalFiles`r`n"
    $logContent += "Successful: $($successfulFiles.Count)`r`n"
    $logContent += "Failed: $($failedFiles.Count)`r`n`r`n"
    $logContent += "Failed Files:`r`n"
    $logContent += "-" * 60 + "`r`n"
    foreach ($failed in $failedFiles) {
        $logContent += "$($failed.FileName)`r`n"
        $logContent += "  Reason: $($failed.Reason)`r`n`r`n"
    }
    $logContent | Out-File -FilePath $logFile -Encoding UTF8
    Write-Host "Error details saved to: $logFile" -ForegroundColor Yellow
}

Write-Host "Finished."


# java -jar saxon9he.jar -s:Toc.xml -xsl:pm_toc.xsl -o:output_toc2.js