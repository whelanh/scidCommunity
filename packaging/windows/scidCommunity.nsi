; scidCommunity Windows installer (NSIS 3.x)
;
; Usage (run from the repository root):
;   makensis /DVERSION=5.1.3.0 /DDISPLAY_VERSION=5.1.3 /DSRCDIR=install packaging\windows\scidCommunity.nsi
;
; VERSION:         4-part numeric version used for the file version resource
; DISPLAY_VERSION: user-visible version, used in the filename and uninstall entry
; SRCDIR:          directory containing the packaged layout (bin/, engines/, lib/, share/, sounds/)

Unicode True

!ifndef VERSION
  !define VERSION "5.1.0.0"
!endif
!ifndef DISPLAY_VERSION
  !define DISPLAY_VERSION "${VERSION}"
!endif
!ifndef SRCDIR
  !define SRCDIR "install"
!endif

!define UNINSTKEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\scidCommunity"

; --- Multi-user (all-users install for admins, per-user for standard users, selectable on the mode page) ---
!define MULTIUSER_EXECUTIONLEVEL Highest
!define MULTIUSER_MUI
!define MULTIUSER_USE_PROGRAMFILES64
!define MULTIUSER_INSTALLMODE_COMMANDLINE
!define MULTIUSER_INSTALLMODE_INSTDIR "scidCommunity"
!define MULTIUSER_INSTALLMODE_INSTDIR_REGISTRY_KEY "Software\scidCommunity"
!define MULTIUSER_INSTALLMODE_INSTDIR_REGISTRY_VALUENAME "InstallDir"
!define MULTIUSER_INSTALLMODE_DEFAULT_REGISTRY_KEY "${UNINSTKEY}"
!define MULTIUSER_INSTALLMODE_DEFAULT_REGISTRY_VALUENAME "CurrentUser"

!include MUI2.nsh
!include x64.nsh
!include MultiUser.nsh

SetCompressor /SOLID lzma

Name "scidCommunity ${DISPLAY_VERSION}"
OutFile "scidCommunity-${DISPLAY_VERSION}-windows-x64-setup.exe"

!define MUI_ICON "resources\win\scid.ico"
!define MUI_UNICON "resources\win\scid.ico"
!define MUI_ABORTWARNING
!define MUI_FINISHPAGE_RUN "$INSTDIR\bin\scidCommunity.exe"

!insertmacro MUI_PAGE_WELCOME
!insertmacro MULTIUSER_PAGE_INSTALLMODE
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "English"

; The installer is a 32-bit process; use the 64-bit registry view on x64 systems
Function .onInit
  ${If} ${RunningX64}
    SetRegView 64
  ${EndIf}
  !insertmacro MULTIUSER_INIT
FunctionEnd

Function un.onInit
  ${If} ${RunningX64}
    SetRegView 64
  ${EndIf}
  !insertmacro MULTIUSER_UNINIT
FunctionEnd

Section "scidCommunity" SEC_MAIN
  SectionIn RO

  SetOutPath "$INSTDIR\bin"
  File "${SRCDIR}\bin\*"

  SetOutPath "$INSTDIR\engines"
  File "${SRCDIR}\engines\*"

  SetOutPath "$INSTDIR"
  File /r "${SRCDIR}\lib"
  File /r "${SRCDIR}\share"
  File /r "${SRCDIR}\sounds"

  WriteUninstaller "$INSTDIR\uninstall.exe"

  WriteRegStr SHCTX "${UNINSTKEY}" "DisplayName" "scidCommunity"
  WriteRegStr SHCTX "${UNINSTKEY}" "DisplayVersion" "${DISPLAY_VERSION}"
  WriteRegStr SHCTX "${UNINSTKEY}" "Publisher" "whelanh"
  WriteRegStr SHCTX "${UNINSTKEY}" "InstallLocation" "$INSTDIR"
  WriteRegStr SHCTX "${UNINSTKEY}" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegStr SHCTX "${UNINSTKEY}" "DisplayIcon" "$INSTDIR\bin\scidCommunity.exe"
  WriteRegStr SHCTX "${UNINSTKEY}" "URLInfoAbout" "https://github.com/whelanh/scidCommunity"
  WriteRegDWORD SHCTX "${UNINSTKEY}" "NoModify" 1
  WriteRegDWORD SHCTX "${UNINSTKEY}" "NoRepair" 1
  WriteRegStr SHCTX "${UNINSTKEY}" "$MultiUser.InstallMode" 1
  WriteRegStr SHCTX "Software\scidCommunity" "InstallDir" "$INSTDIR"

  CreateDirectory "$SMPROGRAMS\scidCommunity"
  CreateShortcut "$SMPROGRAMS\scidCommunity\scidCommunity.lnk" "$INSTDIR\bin\scidCommunity.exe" "" "$INSTDIR\bin\scidCommunity.exe" 0
  CreateShortcut "$SMPROGRAMS\scidCommunity\Uninstall scidCommunity.lnk" "$INSTDIR\uninstall.exe"
SectionEnd

Section "Desktop shortcut" SEC_DESKTOP
  CreateShortcut "$DESKTOP\scidCommunity.lnk" "$INSTDIR\bin\scidCommunity.exe" "" "$INSTDIR\bin\scidCommunity.exe" 0
SectionEnd

Function .onInstSuccess
  SectionGetSize ${SEC_MAIN} $0
  WriteRegDWORD SHCTX "${UNINSTKEY}" "EstimatedSize" $0
FunctionEnd

Section "Uninstall"
  Delete "$DESKTOP\scidCommunity.lnk"
  RMDir /r "$SMPROGRAMS\scidCommunity"

  Delete "$INSTDIR\uninstall.exe"
  RMDir /r "$INSTDIR\bin"
  RMDir /r "$INSTDIR\engines"
  RMDir /r "$INSTDIR\lib"
  RMDir /r "$INSTDIR\share"
  RMDir /r "$INSTDIR\sounds"
  RMDir "$INSTDIR"

  DeleteRegKey SHCTX "${UNINSTKEY}"
  DeleteRegKey SHCTX "Software\scidCommunity"
SectionEnd

VIProductVersion "${VERSION}"
VIAddVersionKey "ProductName" "scidCommunity"
VIAddVersionKey "FileDescription" "scidCommunity installer"
VIAddVersionKey "FileVersion" "${VERSION}"
VIAddVersionKey "ProductVersion" "${DISPLAY_VERSION}"
VIAddVersionKey "LegalCopyright" "GNU General Public License v3"
