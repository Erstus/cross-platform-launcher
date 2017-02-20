#!/bin/bash
#%0 & @ECHO OFF & CLS & GOTO :windows

# Check OS name and unless it's Darwin assume it to be Linux.
if [ `uname` == "Darwin" ]; then OS="macOS"; else OS="Linux"; fi
# Detect architecture by abusing an integer overflow.
if ((1<<32)); then ARCH=64; else ARCH=32; fi
echo -e "Detected system: $OS $ARCH-bit"

# Get parent folder location.
DIR="${BASH_SOURCE%/*}"
if [ ! -d "$DIR" ]; then DIR="$PWD"; fi
# Parse the configuration file.
eval $(sed '/\[Launcher\]/,/^$/!d; s/\[Launcher\]//g; s/\;.*$//g; s/:/=/g; s/ *\= */=/g' $DIR/config.ini)
echo -e "Command: '${!OS}'"

# Execute specified application.
echo -e "Executing..\n"
eval ${!OS}
echo -e "\nScript finished.\n"

# Prevent terminal from closing and quit before Windows code.
exec $SHELL; exit

:windows

:: Determine the architecture by checking Windows' env vars.
IF %PROCESSOR_ARCHITECTURE% == x86 (
    SET ARCH=32
) ELSE (
    SET ARCH=64
)

:: %ARCH% contains the architecture of the OS.
ECHO Detected system: Windows %ARCH%-bit

:: "App" should be replaced with a path of the application.
WHERE /q App >NUL 2>&1 && (
    ECHO Starting App.
    START /WAIT App
    ECHO App has closed.
) || (
    ECHO App not found.
)

:: Prevent command prompt from closing.
CMD /k

:: Exit so the script will not continue into the Linux code.
EXIT
