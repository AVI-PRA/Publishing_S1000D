param(
    [string]$FolderPath = ".",
    [string]$OutFile = "DMC-ICN-Report.xlsx"
)

# Ensure ImportExcel installed
if (-not (Get-Module -ListAvailable -Name ImportExcel)) {
    Install-Module ImportExcel -Scope CurrentUser -Force -AllowClobber
}

function Load-XmlSafe {
    param($Path)
    $settings = New-Object System.Xml.XmlReaderSettings
    $settings.DtdProcessing = "Ignore"
    $settings.IgnoreComments = $true
    $settings.IgnoreProcessingInstructions = $true

    $reader = [System.Xml.XmlReader]::Create($Path, $settings)
    $xml = New-Object System.Xml.XmlDocument
    $xml.Load($reader)
    return $xml
}

# Try multiple possible attribute names and return first non-empty
function Get-FirstAttr {
    param(
        [System.Xml.XmlElement]$el,
        [string[]]$names
    )
    foreach ($n in $names) {
        if ($el -and $el.HasAttribute($n)) {
            $v = $el.GetAttribute($n)
            if ($v -and $v.Trim() -ne "") { return $v.Trim() }
        }
    }
    return $null
}

function Pad-SystemCode {
    param($s)
    if (-not $s) { return $s }
    # if purely numeric, pad to 3 digits (000)
    if ($s -match '^\d+$') { return $s.PadLeft(3,'0') }
    return $s
}

function Get-DmcCodeFromXml {
    param(
        [System.Xml.XmlDocument]$Xml,
        [string]$fileNameFallback
    )

    $dmNode = $Xml.SelectSingleNode("//dmCode")
    if (-not $dmNode) { return $fileNameFallback }

    if ($dmNode -isnot [System.Xml.XmlElement]) { return $fileNameFallback }

    $el = [System.Xml.XmlElement]$dmNode

    # Extract attributes safely
    $model          = Get-FirstAttr -el $el -names @('modelIdentCode')
    $system         = Get-FirstAttr -el $el -names @('systemCode')
    $subSystem      = Get-FirstAttr -el $el -names @('subSystemCode')
    $subSubSystem   = Get-FirstAttr -el $el -names @('subSubSystemCode')
    $assy           = Get-FirstAttr -el $el -names @('assyCode')
    $disassy        = Get-FirstAttr -el $el -names @('disassyCode')
    $disassyControl = Get-FirstAttr -el $el -names @('disassyCodeVariant')
    $itemLocation   = Get-FirstAttr -el $el -names @('infoCode')
    $itemLocation   = Get-FirstAttr -el $el -names @('infoCodeVariant')
    $itemLocation   = Get-FirstAttr -el $el -names @('itemLocationCode')

    # If any required field missing → fallback
    if (-not $model -or -not $system -or -not $subSystem -or -not $subSubSystem -or -not $assy) {
        return $fileNameFallback
    }

    # Pad system code
    $system = Pad-SystemCode $system

    # Build final DMC
    $dmc = "DMC-$model-$system-$subSystem-$subSubSystem-$assy"

    if ($disassy)        { $dmc += "-$disassy" }
    if ($disassyCodeVariant) { $dmc += "-$disassyCodeVariant" }
    if ($itemLocation)   { $dmc += "-$itemLocation" }

    # Remove duplicated hyphens
    $dmc = $dmc -replace '-{2,}','-'

    return $dmc
}


function Get-IcnFromXml {
    param($Xml)

    # Look for any <graphic infoEntityIdent="ICN-xxxx"> or attributes on <figure>/<graphic>
    $graphics = $Xml.SelectNodes("//graphic")
    foreach ($g in $graphics) {
        # Use GetAttribute if available (defensive)
        if ($g -is [System.Xml.XmlElement]) {
            $val = $g.GetAttribute("infoEntityIdent")
            if ($val -and $val -like "ICN-*") { return $val.Trim() }
        } else {
            if ($g.infoEntityIdent -and $g.infoEntityIdent -like "ICN-*") { return $g.infoEntityIdent.Trim() }
        }
    }

    return "NO_ICN_FOUND"
}

Write-Host "`nScanning: $FolderPath`n"

$results = @()

Get-ChildItem -Path $FolderPath -Filter *.xml -File | ForEach-Object {

    Write-Host "Processing $($_.Name)..."

    $filenameBase = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)

    try {
        $xml = Load-XmlSafe -Path $_.FullName

        $dmc = Get-DmcCodeFromXml -Xml $xml -fileNameFallback $filenameBase
        $icn = Get-IcnFromXml -Xml $xml

        $results += [PSCustomObject]@{
            DMC_Code = $dmc
            ICN      = $icn
        }
    }
    catch {
        Write-Host "ERROR parsing XML: $($_.Name)" -ForegroundColor Red

        # 100% guaranteed filename fallback
        $results += [PSCustomObject]@{
            DMC_Code = $filenameBase
            ICN      = "ERROR_PARSING"
        }
    }
}


Write-Host "Generating Excel..."
$results | Export-Excel -Path $OutFile -AutoSize -BoldTopRow -FreezeTopRow

Write-Host "`nDone! Saved: $OutFile"
