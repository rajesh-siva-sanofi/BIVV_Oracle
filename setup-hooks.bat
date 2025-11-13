@echo off
echo Setting up Git hooks for SQL development...

REM Create hooks directory if it doesn't exist
if not exist ".git\hooks" mkdir ".git\hooks"

REM Create pre-commit hook file
echo @echo off > .git\hooks\pre-commit.bat
echo echo Checking for uppercase filenames in db/ directory... >> .git\hooks\pre-commit.bat
echo setlocal enabledelayedexpansion >> .git\hooks\pre-commit.bat
echo set "found_uppercase=0" >> .git\hooks\pre-commit.bat
echo for /f "tokens=*" %%%%a in ('git diff --cached --name-only --diff-filter=ACMR ^| findstr /r "^db/"') do ( >> .git\hooks\pre-commit.bat
echo   set "filename=%%%%~nxa" >> .git\hooks\pre-commit.bat
echo   echo !filename! ^| findstr /r "[A-Z]" > nul >> .git\hooks\pre-commit.bat
echo   if !errorlevel! equ 0 ( >> .git\hooks\pre-commit.bat
echo     if !found_uppercase! equ 0 ( >> .git\hooks\pre-commit.bat
echo       echo. >> .git\hooks\pre-commit.bat
echo       echo ❌ ERROR: Uppercase filenames detected: >> .git\hooks\pre-commit.bat
echo       set "found_uppercase=1" >> .git\hooks\pre-commit.bat
echo     ) >> .git\hooks\pre-commit.bat
echo     echo   - %%%%a >> .git\hooks\pre-commit.bat
echo   ) >> .git\hooks\pre-commit.bat
echo ) >> .git\hooks\pre-commit.bat
echo if !found_uppercase! equ 1 ( >> .git\hooks\pre-commit.bat
echo   echo. >> .git\hooks\pre-commit.bat
echo   echo Team Policy: All filenames under db/ must be lowercase >> .git\hooks\pre-commit.bat
echo   echo. >> .git\hooks\pre-commit.bat
echo   echo Hint: Rename the file to lowercase before committing >> .git\hooks\pre-commit.bat
echo   exit /b 1 >> .git\hooks\pre-commit.bat
echo ) >> .git\hooks\pre-commit.bat
echo exit /b 0 >> .git\hooks\pre-commit.bat

REM Create pre-commit hook file (bash version for Git Bash)
echo #!/bin/bash > .git\hooks\pre-commit
echo echo "Checking for uppercase filenames in db/ directory..." >> .git\hooks\pre-commit
echo STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACMR ^| grep "^db/" ^|^| echo "") >> .git\hooks\pre-commit
echo INVALID_FILES="" >> .git\hooks\pre-commit
echo for file in $STAGED_FILES; do >> .git\hooks\pre-commit
echo   filename=$(basename "$file") >> .git\hooks\pre-commit
echo   if [[ "$filename" =~ [A-Z] ]]; then >> .git\hooks\pre-commit
echo     INVALID_FILES="$INVALID_FILES\n  - $file" >> .git\hooks\pre-commit
echo   fi >> .git\hooks\pre-commit
echo done >> .git\hooks\pre-commit
echo if [[ -n "$INVALID_FILES" ]]; then >> .git\hooks\pre-commit
echo   echo "❌ ERROR: Uppercase filenames detected:" >> .git\hooks\pre-commit
echo   echo -e "$INVALID_FILES" >> .git\hooks\pre-commit
echo   echo "Team Policy: All filenames under db/ must be lowercase" >> .git\hooks\pre-commit
echo   echo >> .git\hooks\pre-commit
echo   echo "Hint: Rename the file to lowercase before committing" >> .git\hooks\pre-commit
echo   exit 1 >> .git\hooks\pre-commit
echo fi >> .git\hooks\pre-commit
echo exit 0 >> .git\hooks\pre-commit

REM Make hooks executable
git config core.hooksPath .git/hooks

echo ✅ Git hooks installed successfully!
echo.
echo Now GitHub Desktop will check for uppercase filenames in db/ directory
echo before allowing commits.
echo.
pause
