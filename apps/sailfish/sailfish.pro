include(../../config.pri)
include(../../i18n/i18n.pri)

CONFIG += sailfishapp

SOURCES += \
    src/main.cpp \
    src/sailfishhelper.cpp

HEADERS += \
    src/sailfishhelper.h

OTHER_FILES += \
    qml/cover/CoverPage.qml \
    xbmcremote.desktop \
    qml/main.qml \
    qml/pages/MainPage.qml \
    qml/pages/AddHostDialog.qml \
    qml/pages/BrowserPage.qml \
    qml/components/Thumbnail.qml \
    qml/icons/icon-cover-stop.png \
    qml/pages/ConnectionDialog.qml \
    qml/components/MenuPlayerControls.qml \
    qml/pages/QuitDialog.qml \
    qml/pages/AboutDialog.qml \
    qml/pages/AuthenticationDialog.qml \
    qml/components/ItemDetails.qml \
    qml/components/NoConnection.qml \
    qml/components/ItemDetailRow.qml \
    qml/pages/SettingsDialog.qml \
    qml/pages/NowPlayingPage.qml \
    qml/components/PlayerControls.qml \
    qml/components/NowPlayingDetails.qml \
    qml/pages/PlaylistPage.qml

