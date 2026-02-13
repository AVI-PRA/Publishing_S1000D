@echo off
setlocal

REM =================================================================
REM CONFIGURE YOUR FOLDERS AND FILES HERE
REM =================================================================
SET SAXON_JAR=saxon9he.jar
SET XML_INPUT_DIR=PMC_Inputs
SET XSL_STYLESHEET=PMtoTOC02.xsl
SET OUTPUT_DIR=TocFiles
REM =================================================================

REM --- Step 1: Check if necessary files and folders exist ---
echo Checking for required items...
if not exist "%SAXON_JAR%" (
    echo ERROR: Saxon JAR not found at "%SAXON_JAR%"
    goto end
)
if not exist "%XML_INPUT_DIR%" (
    echo ERROR: Input directory not found at "%XML_INPUT_DIR%"
    goto end
)
if not exist "%XSL_STYLESHEET%" (
    echo ERROR: XSLT stylesheet not found at "%XSL_STYLESHEET%"
    goto end
)
echo All items found.

REM --- Step 2: Ensure the output directory exists ---
if not exist "%OUTPUT_DIR%" (
    echo Creating output directory: %OUTPUT_DIR%
    mkdir "%OUTPUT_DIR%"
)

REM --- Step 3: Run the Saxon transformation on the entire directory ---
echo Starting directory transformation...
REM Note that -o now points to a directory, not a file.
java -jar "%SAXON_JAR%" -s:"%XML_INPUT_DIR%" -xsl:"%XSL_STYLESHEET%" -o:"%OUTPUT_DIR%"

if %errorlevel% equ 0 (
    echo.
    echo Transformation complete!
    echo Output files saved to the '%OUTPUT_DIR%' directory.
) else (
    echo.
    echo ERROR: The transformation failed. Check for messages above.
)

:end
echo.
pause