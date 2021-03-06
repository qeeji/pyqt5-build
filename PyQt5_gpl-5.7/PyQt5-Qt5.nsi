# PyQt5 NSIS installer script.
# 
# Copyright (c) 2016 Riverbank Computing Limited <info@riverbankcomputing.com>
# 
# This file is part of PyQt5.
# 
# This file may be used under the terms of the GNU General Public License
# version 3.0 as published by the Free Software Foundation and appearing in
# the file LICENSE included in the packaging of this file.  Please review the
# following information to ensure the GNU General Public License version 3.0
# requirements will be met: http://www.gnu.org/copyleft/gpl.html.
# 
# If you do not wish to use this file under the terms of the GPL version 3.0
# then you may purchase a commercial license.  For more information contact
# info@riverbankcomputing.com.
# 
# This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE
# WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.


# These will change with different releases.
!define PYQT_VERSION        "5.7"
!define PYQT_INSTALLER      ""
#!define PYQT_INSTALLER      "-2"
!define PYQT_LICENSE        "GPL"
!define PYQT_LICENSE_LC     "gpl"
!define PYQT_PYTHON_MAJOR   "2"
!define PYQT_PYTHON_MINOR   "7"
!define PYQT_ARCH           "64"
!define PYQT_QT_VERS        "5.6.1"
!define PYQT_QT_DOC_VERS    "5"

# These are all derived from the above.
!define PYQT_PYTHON_DIR     "C:\Python${PYQT_PYTHON_MAJOR}${PYQT_PYTHON_MINOR}"
# !define PYQT_PYTHON_DIR     "d:\venv\pyqt5"
!define PYQT_COMPILE_ROOT  "d:\pyqt5_maya2017"

!define PYQT_PYTHON_VERS    "${PYQT_PYTHON_MAJOR}.${PYQT_PYTHON_MINOR}"
!define PYQT_PYTHON_HK      "Software\Python\PythonCore\${PYQT_PYTHON_VERS}\InstallPath"
!define PYQT_PYTHON_HK_ARCH "Software\Python\PythonCore\${PYQT_PYTHON_VERS}-${PYQT_ARCH}\InstallPath"
!define PYQT_NAME           "PyQt ${PYQT_LICENSE} v${PYQT_VERSION} for Python v${PYQT_PYTHON_VERS} (x${PYQT_ARCH})"
!define PYQT_HK_ROOT        "Software\PyQt5\Py${PYQT_PYTHON_VERS}"
!define PYQT_HK             "${PYQT_HK_ROOT}\InstallPath"
!define PYQT4_HK            "Software\PyQt4\Py${PYQT_PYTHON_VERS}\InstallPath"
# !define QT_SRC_DIR          "C:\Qt\${PYQT_QT_VERS}"
!define QT_SRC_DIR          "${PYQT_COMPILE_ROOT}\Qt\qt-adsk-${PYQT_QT_VERS}\qtbase"

# !define ICU_SRC_DIR         "C:\icu"
!define ICU_SRC_DIR         "${PYQT_COMPILE_ROOT}\icu\dist"

!define OPENSSL_SRC_DIR     "C:\OpenSSL-win64"
!define MYSQL_SRC_DIR       "C:\Program Files\MySQL\MySQL Server 5.7"

# !define REDIST_DIR          "C:\Redist"
!define REDIST_DIR          "C:\Windows\SysWOW64"



# Include the tools we use.
!include MUI2.nsh
!include LogicLib.nsh
!include AddToPath.nsh
!include StrSlash.nsh


# Tweak some of the standard pages.
!define MUI_WELCOMEPAGE_TEXT \
"This wizard will guide you through the installation of ${PYQT_NAME}.$\r$\n\
$\r$\n\
This copy of PyQt includes a subset of Qt v${PYQT_QT_VERS} Open Source \
Edition needed by PyQt. It also includes MySQL, ODBC, PostgreSQL and SQLite \
drivers and the required OpenSSL DLLs.$\r$\n\
$\r$\n\
Any code you write must be released under a license that is compatible with \
the GPL.$\r$\n\
$\r$\n\
CgVFX精神病院 105941496 @衰大$\r$\n\
$\r$\n\
Click Next to continue."

!define MUI_FINISHPAGE_LINK "Get the latest news of PyQt here"
!define MUI_FINISHPAGE_LINK_LOCATION "http://www.riverbankcomputing.com"


# Define the product name and installer executable.
Name "PyQt"
Caption "${PYQT_NAME} Setup"
OutFile "PyQt5-${PYQT_VERSION}-${PYQT_LICENSE_LC}-Py${PYQT_PYTHON_MAJOR}.${PYQT_PYTHON_MINOR}-Qt${PYQT_QT_VERS}-x${PYQT_ARCH}${PYQT_INSTALLER}.exe"


# This is done (along with the use of SetShellVarContext) so that we can remove
# the shortcuts when uninstalling under Vista and Windows 7.  Note that we
# don't actually check if it is successful.
RequestExecutionLevel admin


# The different installation types.  "Full" is everything.  "Minimal" is the
# runtime environment.
InstType "Full"
InstType "Minimal"


# Maximum compression.
SetCompressor /SOLID lzma


# We want the user to confirm they want to cancel.
!define MUI_ABORTWARNING

Function .onInit
    ${If} ${PYQT_ARCH} == "64"
        SetRegView 64
    ${Endif}

    # Check if there is already a version of PyQt4 installed for this version
    # of Python.
    ReadRegStr $0 HKCU "${PYQT4_HK}" ""

    ${If} $0 == ""
        ReadRegStr $0 HKLM "${PYQT4_HK}" ""
    ${Endif}

    ${If} $0 != ""
        MessageBox MB_OK \
"A copy of PyQt4 for Python v${PYQT_PYTHON_VERS} is already installed in $0 \
and must be uninstalled first."
            Abort
    ${Endif}

    # Check if there is already a version of PyQt5 installed for this version
    # of Python.
    ReadRegStr $0 HKCU "${PYQT_HK}" ""

    ${If} $0 == ""
        ReadRegStr $0 HKLM "${PYQT_HK}" ""
    ${Endif}

    ${If} $0 != ""
        MessageBox MB_YESNO|MB_DEFBUTTON2|MB_ICONQUESTION \
"A copy of PyQt5 for Python v${PYQT_PYTHON_VERS} is already installed in $0 \
and should be uninstalled first.$\r$\n \
$\r$\n\
Do you wish to uninstall it?" IDYES Uninstall
            Abort
Uninstall:
        ExecWait '"$0\Lib\site-packages\PyQt5\Uninstall.exe" /S'
    ${Endif}

    # Check the right version of Python has been installed.  Different versions
    # of Python use different formats for the version number.
    ReadRegStr $INSTDIR HKCU "${PYQT_PYTHON_HK}" ""

    ${If} $INSTDIR == ""
        ReadRegStr $INSTDIR HKCU "${PYQT_PYTHON_HK_ARCH}" ""

        ${If} $INSTDIR == ""
            ReadRegStr $INSTDIR HKLM "${PYQT_PYTHON_HK}" ""

            ${If} $INSTDIR == ""
                ReadRegStr $INSTDIR HKLM "${PYQT_PYTHON_HK_ARCH}" ""
            ${Endif}
        ${Endif}
    ${Endif}

    ${If} $INSTDIR == ""
        MessageBox MB_YESNO|MB_ICONQUESTION \
"This copy of PyQt has been built against Python v${PYQT_PYTHON_VERS} \
(x${PYQT_ARCH}) which doesn't seem to be installed.$\r$\n\
$\r$\n\
Do you wish to continue with the installation?" IDYES GotPython
            Abort
GotPython:
        StrCpy $INSTDIR "${PYQT_PYTHON_DIR}"
    ${Endif}
FunctionEnd


# Define the different pages.
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE ".\LICENSE"
!insertmacro MUI_PAGE_COMPONENTS

!define MUI_DIRECTORYPAGE_TEXT_DESTINATION "Python installation folder"
!define MUI_DIRECTORYPAGE_TEXT_TOP \
"PyQt will be installed in the site-packages folder of your Python \
installation."
!insertmacro MUI_PAGE_DIRECTORY

!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

 
# Other settings.
!insertmacro MUI_LANGUAGE "English"


# Installer sections.

Section "Extension modules" SecModules
    SectionIn 1 2 RO

    SetOverwrite on

    # We have to take the SIP files from where they should have been installed.
    SetOutPath $INSTDIR\Lib\site-packages
    File "${PYQT_PYTHON_DIR}\Lib\site-packages\sip.pyd"

    SetOutPath $INSTDIR\Lib\site-packages\PyQt5
    File .\LICENSE
    File .\__init__.py
    File /r .\pyuic\uic

    File .\Qt\Qt.pyd
    File .\QtCore\QtCore.pyd
    File .\QtDesigner\QtDesigner.pyd
    File .\QtGui\QtGui.pyd
    File .\QtHelp\QtHelp.pyd
    File .\QtLocation\QtLocation.pyd
    File .\QtMultimedia\QtMultimedia.pyd
    File .\QtMultimediaWidgets\QtMultimediaWidgets.pyd
    File .\QtNetwork\QtNetwork.pyd
    File .\QtOpenGL\QtOpenGL.pyd
    File .\QtPositioning\QtPositioning.pyd
    File .\QtPrintSupport\QtPrintSupport.pyd
    File .\QtQml\QtQml.pyd
    File .\QtQuick\QtQuick.pyd
    File .\QtQuickWidgets\QtQuickWidgets.pyd
    File .\QtSensors\QtSensors.pyd
    File .\QtSerialPort\QtSerialPort.pyd
    File .\QtSql\QtSql.pyd
    File .\QtSvg\QtSvg.pyd
    File .\QtTest\QtTest.pyd
    File .\QtWebChannel\QtWebChannel.pyd
    # File .\QtWebEngineCore\QtWebEngineCore.pyd
    # File .\QtWebEngineWidgets\QtWebEngineWidgets.pyd
    File .\QtWebSockets\QtWebSockets.pyd
    File .\QtWinExtras\QtWinExtras.pyd
    File .\QtWidgets\QtWidgets.pyd
    File .\QtXml\QtXml.pyd
    File .\QtXmlPatterns\QtXmlPatterns.pyd
    File .\QAxContainer\QAxContainer.pyd
    File .\_QOpenGLFunctions_2_0\_QOpenGLFunctions_2_0.pyd
    File .\_QOpenGLFunctions_2_1\_QOpenGLFunctions_2_1.pyd
    File .\_QOpenGLFunctions_4_1_Core\_QOpenGLFunctions_4_1_Core.pyd
SectionEnd

Section "QScintilla" SecQScintilla
    SectionIn 1

    SetOverwrite on

    SetOutPath $INSTDIR\Lib\site-packages\PyQt5
    File "${PYQT_PYTHON_DIR}\Lib\site-packages\PyQt5\Qsci.pyd"
    File /r "${QT_SRC_DIR}\qsci"

    SetOutPath $INSTDIR\Lib\site-packages\PyQt5
    File "${QT_SRC_DIR}\lib\qscintilla2.dll"

    SetOutPath $INSTDIR\Lib\site-packages\PyQt5\translations
    File "${QT_SRC_DIR}\translations\qscintilla*.qm"
SectionEnd

Section "Qt runtime" SecQt
    SectionIn 1 2

    SetOverwrite on

    SetOutPath $INSTDIR\Lib\site-packages\PyQt5\plugins\PyQt5
    File .\qmlscene\release\pyqt5qmlplugin.dll

    SetOutPath $INSTDIR\Lib\site-packages\PyQt5
    File "${QT_SRC_DIR}\bin\qmlscene.exe"
    File "${QT_SRC_DIR}\bin\Qt5CLucene.dll"
    File "${QT_SRC_DIR}\bin\Qt5Core.dll"
    File "${QT_SRC_DIR}\bin\Qt5Designer.dll"
    File "${QT_SRC_DIR}\bin\Qt5DesignerComponents.dll"
    File "${QT_SRC_DIR}\bin\Qt5Gui.dll"
    File "${QT_SRC_DIR}\bin\Qt5Help.dll"
    File "${QT_SRC_DIR}\bin\Qt5Location.dll"
    File "${QT_SRC_DIR}\bin\Qt5Multimedia.dll"
    File "${QT_SRC_DIR}\bin\Qt5MultimediaQuick_p.dll"
    File "${QT_SRC_DIR}\bin\Qt5MultimediaWidgets.dll"
    File "${QT_SRC_DIR}\bin\Qt5Network.dll"
    File "${QT_SRC_DIR}\bin\Qt5OpenGL.dll"
    File "${QT_SRC_DIR}\bin\Qt5Positioning.dll"
    File "${QT_SRC_DIR}\bin\Qt5PrintSupport.dll"
    File "${QT_SRC_DIR}\bin\Qt5Qml.dll"
    File "${QT_SRC_DIR}\bin\Qt5Quick.dll"
    File "${QT_SRC_DIR}\bin\Qt5QuickParticles.dll"
    File "${QT_SRC_DIR}\bin\Qt5QuickWidgets.dll"
    File "${QT_SRC_DIR}\bin\Qt5Sensors.dll"
    File "${QT_SRC_DIR}\bin\Qt5SerialPort.dll"
    File "${QT_SRC_DIR}\bin\Qt5Sql.dll"
    File "${QT_SRC_DIR}\bin\Qt5Svg.dll"
    File "${QT_SRC_DIR}\bin\Qt5Test.dll"
    File "${QT_SRC_DIR}\bin\Qt5WebChannel.dll"
    # File "${QT_SRC_DIR}\bin\Qt5WebEngineCore.dll"
    # File "${QT_SRC_DIR}\bin\Qt5WebEngineWidgets.dll"
    File "${QT_SRC_DIR}\bin\Qt5WebSockets.dll"
    File "${QT_SRC_DIR}\bin\Qt5Widgets.dll"
    File "${QT_SRC_DIR}\bin\Qt5WinExtras.dll"
    File "${QT_SRC_DIR}\bin\Qt5Xml.dll"
    File "${QT_SRC_DIR}\bin\Qt5XmlPatterns.dll"
    # File "${QT_SRC_DIR}\bin\QtWebEngineProcess.exe"

    File "${QT_SRC_DIR}\bin\libEGL.dll"
    File "${QT_SRC_DIR}\bin\libGLESv2.dll"

    File "${ICU_SRC_DIR}\lib\icudt57.dll"
    File "${ICU_SRC_DIR}\lib\icuin57.dll"
    File "${ICU_SRC_DIR}\lib\icuuc57.dll"

    File "${OPENSSL_SRC_DIR}\bin\libeay32.dll"
    File "${OPENSSL_SRC_DIR}\bin\ssleay32.dll"

    File "${MYSQL_SRC_DIR}\lib\libmysql.dll"

    File "${REDIST_DIR}\msvcp140.dll"

    SetOutPath $INSTDIR\Lib\site-packages\PyQt5
    File /r "${QT_SRC_DIR}\qml"

    SetOutPath $INSTDIR\Lib\site-packages\PyQt5\plugins\audio
    File "${QT_SRC_DIR}\plugins\audio\qtaudio_windows.dll"

    SetOutPath $INSTDIR\Lib\site-packages\PyQt5\plugins\bearer
    File "${QT_SRC_DIR}\plugins\bearer\qgenericbearer.dll"
    File "${QT_SRC_DIR}\plugins\bearer\qnativewifibearer.dll"

    SetOutPath $INSTDIR\Lib\site-packages\PyQt5\plugins\geoservices
    File "${QT_SRC_DIR}\plugins\geoservices\qtgeoservices_mapbox.dll"
    File "${QT_SRC_DIR}\plugins\geoservices\qtgeoservices_nokia.dll"
    File "${QT_SRC_DIR}\plugins\geoservices\qtgeoservices_osm.dll"

    SetOutPath $INSTDIR\Lib\site-packages\PyQt5\plugins\iconengines
    File "${QT_SRC_DIR}\plugins\iconengines\qsvgicon.dll"

    SetOutPath $INSTDIR\Lib\site-packages\PyQt5\plugins\imageformats
    File "${QT_SRC_DIR}\plugins\imageformats\qdds.dll"
    File "${QT_SRC_DIR}\plugins\imageformats\qgif.dll"
    File "${QT_SRC_DIR}\plugins\imageformats\qicns.dll"
    File "${QT_SRC_DIR}\plugins\imageformats\qico.dll"
    File "${QT_SRC_DIR}\plugins\imageformats\qjpeg.dll"
    File "${QT_SRC_DIR}\plugins\imageformats\qsvg.dll"
    File "${QT_SRC_DIR}\plugins\imageformats\qtga.dll"
    File "${QT_SRC_DIR}\plugins\imageformats\qtiff.dll"
    File "${QT_SRC_DIR}\plugins\imageformats\qwbmp.dll"
    File "${QT_SRC_DIR}\plugins\imageformats\qwebp.dll"

    SetOutPath $INSTDIR\Lib\site-packages\PyQt5\plugins\mediaservice
    File "${QT_SRC_DIR}\plugins\mediaservice\dsengine.dll"
    File "${QT_SRC_DIR}\plugins\mediaservice\qtmedia_audioengine.dll"

    SetOutPath $INSTDIR\Lib\site-packages\PyQt5\plugins\platforms
    File "${QT_SRC_DIR}\plugins\platforms\qminimal.dll"
    File "${QT_SRC_DIR}\plugins\platforms\qoffscreen.dll"
    File "${QT_SRC_DIR}\plugins\platforms\qwindows.dll"

    SetOutPath $INSTDIR\Lib\site-packages\PyQt5\plugins\playlistformats
    File "${QT_SRC_DIR}\plugins\playlistformats\qtmultimedia_m3u.dll"

    SetOutPath $INSTDIR\Lib\site-packages\PyQt5\plugins\position
    File "${QT_SRC_DIR}\plugins\position\qtposition_geoclue.dll"
    File "${QT_SRC_DIR}\plugins\position\qtposition_positionpoll.dll"
    File "${QT_SRC_DIR}\plugins\position\qtposition_serialnmea.dll"

    SetOutPath $INSTDIR\Lib\site-packages\PyQt5\plugins\printsupport
    File "${QT_SRC_DIR}\plugins\printsupport\windowsprintersupport.dll"

    SetOutPath $INSTDIR\Lib\site-packages\PyQt5\plugins\sensorgestures
    File "${QT_SRC_DIR}\plugins\sensorgestures\qtsensorgestures_plugin.dll"
    File "${QT_SRC_DIR}\plugins\sensorgestures\qtsensorgestures_shakeplugin.dll"

    SetOutPath $INSTDIR\Lib\site-packages\PyQt5\plugins\sensors
    File "${QT_SRC_DIR}\plugins\sensors\qtsensors_generic.dll"

    SetOutPath $INSTDIR\Lib\site-packages\PyQt5\plugins\sqldrivers
    File "${QT_SRC_DIR}\plugins\sqldrivers\qsqlite.dll"
    File "${QT_SRC_DIR}\plugins\sqldrivers\qsqlmysql.dll"
    File "${QT_SRC_DIR}\plugins\sqldrivers\qsqlodbc.dll"
    File "${QT_SRC_DIR}\plugins\sqldrivers\qsqlpsql.dll"

    SetOutPath $INSTDIR\Lib\site-packages\PyQt5\resources
    File /r "${QT_SRC_DIR}\resources"

    SetOutPath $INSTDIR\Lib\site-packages\PyQt5\translations
    File "${QT_SRC_DIR}\translations\qt_*.qm"
    File "${QT_SRC_DIR}\translations\qtbase_*.qm"

    # SetOutPath $INSTDIR\Lib\site-packages\PyQt5\translations\qtwebengine_locales
    # File /r "${QT_SRC_DIR}\translations\qtwebengine_locales"

    # Tell Python and the Qt tools where to find Qt.
    FileOpen $0 $INSTDIR\qt.conf w
    FileWrite $0 "[Paths]$\r$\n"
    FileWrite $0 "Prefix = Lib/site-packages/PyQt5$\r$\n"
    FileWrite $0 "Binaries = Lib/site-packages/PyQt5$\r$\n"
    FileClose $0

    FileOpen $0 $INSTDIR\Lib\site-packages\PyQt5\qt.conf w
    FileWrite $0 "[Paths]$\r$\n"
    FileWrite $0 "Prefix = .$\r$\n"
    FileWrite $0 "Binaries = .$\r$\n"
    FileClose $0
SectionEnd

Section "Developer tools" SecTools
    SectionIn 1

    SetOverwrite on

    SetOutPath $INSTDIR\Lib\site-packages\PyQt5
    File ".\sip\pyrcc\pyrcc_main.py"
    File ".\pyrcc\pyrcc.pyd"
    File ".\sip\pylupdate\pylupdate_main.py"
    File ".\pylupdate\pylupdate.pyd"

    SetOutPath $INSTDIR
    # File .\pylupdate\release\pylupdate5.exe
    # File .\pyrcc\release\pyrcc5.exe

    FileOpen $0 $INSTDIR\Lib\site-packages\PyQt5\pyuic5.bat w
    FileWrite $0 "@$\"$INSTDIR\python$\" -m PyQt5.uic.pyuic %1 %2 %3 %4 %5 %6 %7 %8 %9$\r$\n"
    FileClose $0

    FileOpen $0 $INSTDIR\Lib\site-packages\PyQt5\pyrcc5.bat w
    FileWrite $0 "@$\"$INSTDIR\python$\" -m PyQt5.pyrcc_main %1 %2 %3 %4 %5 %6 %7 %8 %9$\r$\n"
    FileClose $0

    FileOpen $0 $INSTDIR\Lib\site-packages\PyQt5\pylupdate5.bat w
    FileWrite $0 "@$\"$INSTDIR\python$\" -m PyQt5.pylupdate_main %1 %2 %3 %4 %5 %6 %7 %8 %9$\r$\n"
    FileClose $0

SectionEnd

Section "Qt developer tools" SecQtTools
    SectionIn 1

    SetOverwrite on

    SetOutPath $INSTDIR\Lib\site-packages\PyQt5
    File "${QT_SRC_DIR}\bin\assistant.exe"
    File "${QT_SRC_DIR}\bin\designer.exe"
    File "${QT_SRC_DIR}\bin\linguist.exe"
    File "${QT_SRC_DIR}\bin\lrelease.exe"
    File "${QT_SRC_DIR}\bin\qcollectiongenerator.exe"
    File "${QT_SRC_DIR}\bin\qhelpgenerator.exe"
    File "${QT_SRC_DIR}\bin\qmake.exe"
    File "${QT_SRC_DIR}\bin\xmlpatterns.exe"
    File /r "${QT_SRC_DIR}\mkspecs"

    SetOutPath $INSTDIR\Lib\site-packages\PyQt5\plugins\designer
    File "${QT_SRC_DIR}\plugins\designer\qaxwidget.dll"
    File "${QT_SRC_DIR}\plugins\designer\qquickwidget.dll"

    File .\designer\release\pyqt5.dll
    File "${QT_SRC_DIR}\plugins\designer\qscintillaplugin.dll"

    SetOutPath $INSTDIR\Lib\site-packages\PyQt5\translations
    File "${QT_SRC_DIR}\translations\assistant_*.qm"
    File "${QT_SRC_DIR}\translations\designer_*.qm"
    File "${QT_SRC_DIR}\translations\linguist_*.qm"
SectionEnd

Section "SIP developer tools" SecSIPTools
    SectionIn 1

    SetOverwrite on

    SetOutPath $INSTDIR\Lib\site-packages\PyQt5
    # File /r "${PYQT_PYTHON_DIR}\Lib\site-packages\PyQt5\sip"
    File /r "${PYQT_PYTHON_DIR}\sip"

    SetOutPath $INSTDIR\Lib\site-packages\PyQt5
    # File "${PYQT_PYTHON_DIR}\Lib\site-packages\PyQt5\sip.exe"
    File "${PYQT_PYTHON_DIR}\sip.exe"

    SetOutPath $INSTDIR\Lib\site-packages\PyQt5\include
    # File "${PYQT_PYTHON_DIR}\Lib\site-packages\PyQt5\include\sip.h"
    File "${PYQT_PYTHON_DIR}\include\sip.h"
SectionEnd

Section "Documentation" SecDocumentation
    SectionIn 1

    SetOverwrite on

    SetOutPath $INSTDIR\Lib\site-packages\PyQt5
    File /r .\doc
SectionEnd

Section "Examples" SecExamples
    SectionIn 1

    SetOverwrite on

    SetOutPath $INSTDIR\Lib\site-packages\PyQt5
    File /r .\examples

    Rename $INSTDIR\Lib\site-packages\PyQt5\examples\qtdemo\qtdemo.py $INSTDIR\Lib\site-packages\PyQt5\examples\qtdemo\qtdemo.pyw

    # Tell the QtQuick plugins example to find the plugin.
    Push $INSTDIR
    Push "\"
    Call StrSlash
    Pop $R0

    FileOpen $0 $INSTDIR\Lib\site-packages\PyQt5\examples\quick\tutorials\extending\chapter6-plugins\Charts\qmldir w
    FileWrite $0 "module Charts$\r$\n" 
    FileWrite $0 "plugin pyqt5qmlplugin $R0/Lib/site-packages/PyQt5/plugins/PyQt5$\r$\n"
    FileClose $0
SectionEnd

Section "Start Menu shortcuts" SecShortcuts
    SectionIn 1

    SetShellVarContext all

    # Make sure this is clean and tidy.
    RMDir /r "$SMPROGRAMS\${PYQT_NAME}"
    CreateDirectory "$SMPROGRAMS\${PYQT_NAME}"

    IfFileExists "$INSTDIR\Lib\site-packages\PyQt5\assistant.exe" 0 +4
        CreateShortCut "$SMPROGRAMS\${PYQT_NAME}\Assistant.lnk" "$INSTDIR\Lib\site-packages\PyQt5\assistant.exe"
        CreateShortCut "$SMPROGRAMS\${PYQT_NAME}\Designer.lnk" "$INSTDIR\Lib\site-packages\PyQt5\designer.exe"
        CreateShortCut "$SMPROGRAMS\${PYQT_NAME}\Linguist.lnk" "$INSTDIR\Lib\site-packages\PyQt5\linguist.exe"

    IfFileExists "$INSTDIR\Lib\site-packages\PyQt5\doc" 0 +5
        CreateDirectory "$SMPROGRAMS\${PYQT_NAME}\Documentation"
        CreateShortCut "$SMPROGRAMS\${PYQT_NAME}\Documentation\PyQt Reference Guide.lnk" "$INSTDIR\Lib\site-packages\PyQt5\doc\html\index.html"
	CreateShortCut "$SMPROGRAMS\${PYQT_NAME}\Documentation\Qt Documentation.lnk" "http://qt-project.org/doc/qt-${PYQT_QT_DOC_VERS}/"

    IfFileExists "$INSTDIR\Lib\site-packages\PyQt5\examples" 0 +6
        CreateDirectory "$SMPROGRAMS\${PYQT_NAME}\Examples"
	SetOutPath $INSTDIR\Lib\site-packages\PyQt5\examples\qtdemo
        CreateShortCut "$SMPROGRAMS\${PYQT_NAME}\Examples\PyQt Examples.lnk" "$INSTDIR\Lib\site-packages\PyQt5\examples\qtdemo\qtdemo.pyw"
	SetOutPath $INSTDIR
        CreateShortCut "$SMPROGRAMS\${PYQT_NAME}\Examples\PyQt Examples Source.lnk" "$INSTDIR\Lib\site-packages\PyQt5\examples"

    CreateDirectory "$SMPROGRAMS\${PYQT_NAME}\Links"
    CreateShortCut "$SMPROGRAMS\${PYQT_NAME}\Links\PyQt Book.lnk" "http://www.qtrac.eu/pyqtbook.html"
    CreateShortCut "$SMPROGRAMS\${PYQT_NAME}\Links\PyQt Homepage.lnk" "http://www.riverbankcomputing.com/software/pyqt/"
    CreateShortCut "$SMPROGRAMS\${PYQT_NAME}\Links\Qt Homepage.lnk" "http://qt.digia.com"
    CreateShortCut "$SMPROGRAMS\${PYQT_NAME}\Links\QScintilla Homepage.lnk" "http://www.riverbankcomputing.com/software/qscintilla/"
    CreateShortCut "$SMPROGRAMS\${PYQT_NAME}\Links\eric Homepage.lnk" "http://eric-ide.python-projects.org/index.html"

    CreateShortCut "$SMPROGRAMS\${PYQT_NAME}\Uninstall PyQt.lnk" "$INSTDIR\Lib\site-packages\PyQt5\Uninstall.exe"
SectionEnd

Section -post
    # Add the bin directory to PATH.
    Push $INSTDIR\Lib\site-packages\PyQt5
    Call AddToPath

    # Tell Windows about the package.
    WriteRegExpandStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PYQT_NAME}" "UninstallString" '"$INSTDIR\Lib\site-packages\PyQt5\Uninstall.exe"'
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PYQT_NAME}" "DisplayName" "${PYQT_NAME}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PYQT_NAME}" "DisplayVersion" "${PYQT_VERSION}${PYQT_INSTALLER}"
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PYQT_NAME}" "NoModify" "1"
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PYQT_NAME}" "NoRepair" "1"

    # Save the installation directories for the uninstaller.
    ClearErrors
    WriteRegStr HKLM "${PYQT_HK}" "" $INSTDIR
    IfErrors 0 +2
        WriteRegStr HKCU "${PYQT_HK}" "" $INSTDIR

    # Create the uninstaller.
    WriteUninstaller "$INSTDIR\Lib\site-packages\PyQt5\Uninstall.exe"
SectionEnd


# Section description text.
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
!insertmacro MUI_DESCRIPTION_TEXT ${SecModules} \
"The PyQt and sip extension modules."
!insertmacro MUI_DESCRIPTION_TEXT ${SecQScintilla} \
"QScintilla and its extension module."
!insertmacro MUI_DESCRIPTION_TEXT ${SecQt} \
"The Qt DLLs, plugins and translations."
!insertmacro MUI_DESCRIPTION_TEXT ${SecQtTools} \
"The Qt developer tools: Assistant, Designer, Linguist etc."
!insertmacro MUI_DESCRIPTION_TEXT ${SecTools} \
"The PyQt developer tools: pyuic5, pyrcc5 and pylupdate5."
!insertmacro MUI_DESCRIPTION_TEXT ${SecSIPTools} \
"The SIP developer tools and .sip files."
!insertmacro MUI_DESCRIPTION_TEXT ${SecDocumentation} \
"The PyQt and related documentation."
!insertmacro MUI_DESCRIPTION_TEXT ${SecExamples} \
"Ports to Python of the standard Qt v5 examples."
!insertmacro MUI_DESCRIPTION_TEXT ${SecShortcuts} \
"This adds shortcuts to your Start Menu."
!insertmacro MUI_FUNCTION_DESCRIPTION_END


Function un.onInit
    ${If} ${PYQT_ARCH} == "64"
        SetRegView 64
    ${Endif}

    # Get the PyQt installation directory.
    ReadRegStr $INSTDIR HKCU "${PYQT_HK}" ""

    ${If} $INSTDIR == ""
        ReadRegStr $INSTDIR HKLM "${PYQT_HK}" ""

        ${If} $INSTDIR == ""
            # Try where Python was installed.
            ReadRegStr $INSTDIR HKCU "${PYQT_PYTHON_HK}" ""

            ${If} $INSTDIR == ""
                ReadRegStr $INSTDIR HKCU "${PYQT_PYTHON_HK_ARCH}" ""

                ${If} $INSTDIR == ""
                    ReadRegStr $INSTDIR HKLM "${PYQT_PYTHON_HK}" ""

                    ${If} $INSTDIR != ""
                        ReadRegStr $INSTDIR HKLM "${PYQT_PYTHON_HK_ARCH}" ""

                        ${If} $INSTDIR != ""
                            # Default to where Python should be installed (at
                            # least prior to v3.5).
                            StrCpy $INSTDIR "${PYQT_PYTHON_DIR}\"
                        ${Endif}
                    ${Endif}
                ${Endif}
            ${Endif}
        ${Endif}
    ${Endif}
FunctionEnd


Section "Uninstall"
    SetShellVarContext all

    # Remove the bin directory from PATH.
    Push $INSTDIR\Lib\site-packages\PyQt5
    Call un.RemoveFromPath

    # The Qt path file.
    Delete $INSTDIR\qt.conf

    # The modules section.
    Delete $INSTDIR\Lib\site-packages\sip.pyd
    RMDir /r $INSTDIR\Lib\site-packages\PyQt5

    # The shortcuts section.
    RMDir /r "$SMPROGRAMS\${PYQT_NAME}"

    # Clean the registry.
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PYQT_NAME}"
    DeleteRegKey HKLM "${PYQT_HK_ROOT}"
    DeleteRegKey HKCU "${PYQT_HK_ROOT}"
SectionEnd
