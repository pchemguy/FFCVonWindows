@echo off

echo ==========================================================================
echo Activating Git For Windows
echo:
echo %WARN% CLI: "%~f0" %*
echo ==========================================================================

if exist "E:\PortablePrograms\GitForWindows\activate.bat" (
  echo Running "E:\PortablePrograms\GitForWindows\activate.bat"
  call "E:\PortablePrograms\GitForWindows\activate.bat"
) else (
  if exist "%SystemDrive%\PortablePrograms\GitForWindows\activate.bat" (
    echo Running "%SystemDrive%\PortablePrograms\GitForWindows\activate.bat"
    call "%SystemDrive%\PortablePrograms\GitForWindows\activate.bat"
  ) else (
    echo [ERROR] Git For Windows not found...
    exit /b 1
  )
)

call "%~dp0conda_far.bat" %*
