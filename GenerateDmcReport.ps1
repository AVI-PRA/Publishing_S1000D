param(
    [string]$FolderPath = ".",
    [string]$OutFile = "DMC-Report.xlsx"
)

# Load Excel package from PoShExcel module
if (-not (Get-Module -ListAvailable -Name ImportExcel)) {
    Write-Host "ImportExcel module not found, installing..."
    Install-Module ImportExcel -Scope CurrentUser -Force -AllowClobber
}

function Get-DmcCode {
    param($FileName)

    # REGEX for DMC code (captures full DMC-xxxx string)
    if ($FileName -match "(DMC-[A-Za-z0-9\-]+)") {
        return $matches[1]
    }
    return "UNKNOWN"
}

Write-Host "`nScanning folder: $FolderPath ..."

$results = @()

Get-ChildItem -Path $FolderPath -File | ForEach-Object {
    $dmc = Get-DmcCode -FileName $_.Name

    $results += [PSCustomObject]@{
        DMC_Code  = $dmc
        File_Name = $_.Name
    }
}

Write-Host "Grouping files by DMC code..."

$grouped = $results | Group-Object DMC_Code | ForEach-Object {
    [PSCustomObject]@{
        DMC_Code  = $_.Name
        Files     = ($_.Group.File_Name -join "`n")
    }
}

Write-Host "Creating Excel file: $OutFile ..."
$grouped | Export-Excel -Path $OutFile -AutoSize -BoldTopRow -FreezeTopRow

Write-Host "Done! Excel saved as: $OutFile"
