@echo off
setlocal enabledelayedexpansion

REM =================================================================
REM CONFIGURATION
REM =================================================================
SET "SAXON_JAR=saxon9he.jar"
SET XML_INPUT_DIR=PMC_Inputs
SET "XSL_STYLESHEET=PMtoTOC02.xsl"
SET "OUTPUT_DIR=TocFiles"
SET "OUTPUT_FILENAME=Toc.js"
REM =================================================================

echo.
echo ================================================================
echo Checking for required files and directories...
echo ================================================================

SET "OUTPUT_FILE=%OUTPUT_DIR%\%OUTPUT_FILENAME%"

if not exist "%SAXON_JAR%" (
    echo [ERROR] Saxon JAR not found: "%SAXON_JAR%"
    goto end
)
if not exist "%XML_INPUT_DIR%" (
    echo [ERROR] Input directory not found: "%XML_INPUT_DIR%"
    goto end
)
if not exist "%XSL_STYLESHEET%" (
    echo [ERROR] Stylesheet not found: "%XSL_STYLESHEET%"
    goto end
)
echo All required items found.

REM --- Ensure output directory exists ---
if not exist "%OUTPUT_DIR%" (
    echo Creating output directory: %OUTPUT_DIR%
    mkdir "%OUTPUT_DIR%"
)

REM --- Initialize/clear output file ---
echo // Auto-generated JS from XML transformation > "%OUTPUT_FILE%"
echo. >> "%OUTPUT_FILE%"

REM --- Process each XML file ---
echo.
echo Transforming XML files in "%XML_INPUT_DIR%"...

for %%F in ("%XML_INPUT_DIR%\*.xml") do (
    echo Processing: %%~nxF
    java -jar "%SAXON_JAR%" -s:"%%F" -xsl:"%XSL_STYLESHEET%" -o:"%OUTPUT_DIR%\temp.js"
    if !errorlevel! neq 0 (
        echo [ERROR] Failed: %%~nxF
        goto end
    )
    type "%OUTPUT_DIR%\temp.js" >> "%OUTPUT_FILE%"
    echo. >> "%OUTPUT_FILE%"
)

del "%OUTPUT_DIR%\temp.js" >nul 2>&1

echo.
echo ================================================================
echo ✅ Transformation complete!
echo Output saved to: "%OUTPUT_FILE%"
echo ================================================================

:end
echo.
pause
