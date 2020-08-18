; runabc.nsi
;
; This script is based on example1.nsi, but it remember the directory, 
; has uninstall support and (optionally) installs start menu shortcuts.
;
; It will install example2.nsi into a directory that the user selects,

;--------------------------------

; The name of the installer
Name "Runabc installer"

; The file to write
OutFile "Runabc_setup.exe"

; The default installation directory
InstallDir c:\Runabc

; Registry key to check for directory (so if you install again, it will 
; overwrite the old one automatically)
InstallDirRegKey HKLM "Software\Runabc" "Install_Dir"

;--------------------------------

; Pages

Page components
Page directory
Page instfiles

UninstPage uninstConfirm
UninstPage instfiles

;--------------------------------

; The stuff to install
Section "Runabc (required)"

  SectionIn RO
  
  ; Set output path to the installation directory.
  SetOutPath $INSTDIR
  
  ; Put file there
  File "runabc.exe"
  File "runabc.ico"
  File "abc2midi.exe"
  File "yaps.exe"
  File "abc2abc.exe"
  File "abcm2ps.exe"
  File "midicopy.exe"
  File "abcmatch.exe"
  File "midi2abc.exe"
  File "samples.abc"
  ; Write the installation path into the registry
  WriteRegStr HKLM SOFTWARE\NSIS_Example2 "Install_Dir" "$INSTDIR"
  
  ; Write the uninstall keys for Windows
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Runabc" "DisplayName" "Runabc"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Runabc" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Runabc" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Example2" "NoRepair" 1
  WriteUninstaller "uninstall.exe"
  
SectionEnd

; Optional section (can be disabled by the user)
Section "Start Menu Shortcuts"

  CreateDirectory "$SMPROGRAMS\Runabc"
  CreateShortCut "$SMPROGRAMS\Runabc\Runabc.lnk" "$INSTDIR\runabc.exe" "" "$INSTDIR\runabc.exe" 0
  CreateShortCut "$SMPROGRAMS\Runabc\Uninstall.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\uninstall.exe" 0
SectionEnd

Section "Desktop Shortcut"
  CreateShortCut "$DESKTOP\Runabc.lnk" "$INSTDIR\runabc.exe" "" 
SectionEnd

;--------------------------------

; Uninstaller

Section "Uninstall"
  
  ; Remove registry keys
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Runabc"
  DeleteRegKey HKLM SOFTWARE\Runabc

  ; Remove files and uninstaller
  Delete $INSTDIR\runabc.exe
  RMDIR /r $INSTDIR\..\Runabc
  Delete $INSTDIR\uninstall.exe

  ; Remove shortcuts, if any
  Delete "$SMPROGRAMS\Runabc\*.*"
  Delete "$DESKTOP\Runabc.lnk"

  ; Remove directories used
  RMDir "$SMPROGRAMS\Runabc"
  RMDir "$INSTDIR"

SectionEnd
