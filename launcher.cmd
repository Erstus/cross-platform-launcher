#!/bin/bash
#%0 & @ECHO OFF & CLS & GOTO :windows

# Check OS name and unless it's Darwin assume it to be Linux.
if [ `uname` == "Darwin" ]; then OS="macOS"; else OS="Linux"; fi

# Detect architecture by abusing an integer overflow.
if ((1<<32)); then ARCH=64; else ARCH=32; fi

echo -e "Detected system: $OS $ARCH-bit"

# Get OS specific instructions from external file.
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
source <(grep = "$DIR/config.ini" | sed 's/ *= */=/g')

echo -e "Command: ${!OS}"

# Execute specified application.
if [ ! -x "$(command -v ${!OS})" ]; then
  echo "Could not execute."
else
  echo -e "Executing..\n"
  eval ${!OS}
  echo -e "\nScript finished.\n"
fi

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
