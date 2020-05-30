include(../../config.pri)
include(../../i18n/i18n.pri)

TARGET = harbour-kodimote

STORE = ""

CONFIG += sailfishapp

QT += dbus
INCLUDEPATH += /usr/include/resource/qt5
PKGCONFIG += libresourceqt5

contains(STORE, harbour) {
    DEFINES += HARBOUR_BUILD=
} else {
    CONFIG += Qt5Contacts
    PKGCONFIG += Qt5Contacts keepalive
}

SOURCES += \
    src/main.cpp \
    src/sailfishhelper.cpp

HEADERS += \
    src/sailfishhelper.h

OTHER_FILES += \
    qml/cover/CoverPage.qml \
    harbour-kodimote.desktop \
    qml/main.qml \
    qml/pages/MainPage.qml \
    qml/pages/AddHostDialog.qml \
    qml/pages/BrowserPage.qml \
    qml/components/Thumbnail.qml \
    qml/icons/icon-cover-stop.png \
    qml/icons/icon-cover-stop-rev.png \
    qml/pages/ConnectionDialog.qml \
    qml/pages/AboutDialog.qml \
    qml/pages/AuthenticationDialog.qml \
    qml/components/ItemDetails.qml \
    qml/components/NoConnection.qml \
    qml/components/ItemDetailRow.qml \
    qml/pages/SettingsDialog.qml \
    qml/pages/NowPlayingPage.qml \
    qml/components/PlayerControls.qml \
    qml/components/NowPlayingDetails.qml \
    qml/pages/PlaylistPage.qml \
    qml/pages/MediaSelectionDialog.qml \
    qml/pages/Keypad.qml \
    qml/components/GesturePad.qml \
    qml/pages/KodiPage.qml \
    qml/components/ChannelDetails.qml \
    qml/components/DockedControls.qml \
    qml/components/ControlsMenuItem.qml \
    qml/pages/ProfileSelectionDialog.qml \
    qml/pages/ResumeDialog.qml \
    qml/pages/YouTubeSendPage.qml

icon86.files += icons/86x86/harbour-kodimote.png
icon86.path = /usr/share/icons/hicolor/86x86/apps

icon108.files += icons/108x108/harbour-kodimote.png
icon108.path = /usr/share/icons/hicolor/108x108/apps

icon128.files += icons/128x128/harbour-kodimote.png
icon128.path = /usr/share/icons/hicolor/128x128/apps

icon172.files += icons/172x172/harbour-kodimote.png
icon172.path = /usr/share/icons/hicolor/172x172/apps

icon256.files += icons/256x256/harbour-kodimote.png
icon256.path = /usr/share/icons/hicolor/256x256/apps

INSTALLS += icon86 icon108 icon128 icon172 icon256
