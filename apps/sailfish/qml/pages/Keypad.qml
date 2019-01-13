
/*****************************************************************************
 * Copyright: 2011-2013 Michael Zanetti <michael_zanetti@gmx.net>            *
 *            2014      Robert Meijers <robert.meijers@gmail.com>            *
 *                                                                           *
 * This file is part of Kodimote                                             *
 *                                                                           *
 * Kodimote is free software: you can redistribute it and/or modify          *
 * it under the terms of the GNU General Public License as published by      *
 * the Free Software Foundation, either version 3 of the License, or         *
 * (at your option) any later version.                                       *
 *                                                                           *
 * Kodimote is distributed in the hope that it will be useful,               *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of            *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             *
 * GNU General Public License for more details.                              *
 *                                                                           *
 * You should have received a copy of the GNU General Public License         *
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.     *
 *                                                                           *
 ****************************************************************************/
import QtQuick 2.0
import Sailfish.Silica 1.0
import QtFeedback 5.0
import harbour.kodimote 1.0
import "../components/"

Page {
    id: keypad
    allowedOrientations: appWindow.orientationSetting

    property QtObject player: kodi.activePlayer
    property QtObject picturePlayer: kodi.picturePlayer()

    property bool usePictureControls: kodi.picturePlayerActive
                                      && !pictureControlsOverride
    property bool pictureControlsOverride: false

    property QtObject keys: kodi.keys()
    property bool timerActive: ((Qt.application.active
                                 && keypad.status == PageStatus.Active)
                                || cover.status === Cover.Active)
                               && cover.status !== Cover.Deactivating
                               && dockedControls.open

    HapticsEffect {
        id: rumbleEffect
        intensity: 0.50
        duration: 50
    }

    DisplayBlanking {
        preventBlanking: keypad.status === PageStatus.Active
                         && Qt.application.active && settings.preventDimEnabled
    }

    onStatusChanged: {
        if (status === PageStatus.Active) {
            dockedControls.hideTemporary = settings.introStep < Settings.IntroStepDone
            pageStack.pushAttached("NowPlayingPage.qml")
        } else {
            dockedControls.hideTemporary = false
        }
    }

    onTimerActiveChanged: {
        player.timerActive = timerActive
    }

    Connections {
        target: settings
        onIntroStepChanged: {
            dockedControls.hideTemporary = settings.introStep < Settings.IntroStepDone
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        pressDelay: 0

        VerticalScrollDecorator {
        }

        PullDownMenu {
            visible: kodi.activePlayer || kodi.picturePlayerActive
            ControlsMenuItem {
            }

            MenuItem {
                enabled: kodi.picturePlayerActive
                text: !enabled
                      || usePictureControls ? qsTr(
                                                  "Pictures Mode (off)") : qsTr(
                                                  "Pictures Mode (on)")
                onClicked: {
                    pictureControlsOverride = !pictureControlsOverride
                }
            }
        }

        Column {
            id: column

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Theme.paddingLarge
            anchors.rightMargin: Theme.paddingLarge
            spacing: appWindow.smallestScreen ? Theme.paddingLarge : Theme.paddingLarge * 1.5

            PageHeader {
                id: header
                title: qsTr("Keypad")
                visible: isPortrait
            }

            Rectangle {
                width: parent.width
                color: "transparent"
                visible: isPortrait
                border.color: Theme.rgba(Theme.highlightColor,
                                         Theme.highlightBackgroundOpacity)
                border.width: 2
                radius: 10
                height: Theme.itemSizeMedium

                Label {
                    id: introLabel1
                    anchors {
                        fill: parent
                        leftMargin: Theme.paddingSmall
                        rightMargin: Theme.paddingSmall
                    }
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WordWrap
                    opacity: settings.introStep < Settings.IntroStepDone ? 1 : 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 500
                        }
                    }
                    color: "white"
                    text: {
                        switch (settings.introStep) {
                        case Settings.IntroStepLeftRight:
                            return qsTr("To move left or right, swipe horizontally anywhere on the pad.")
                        case Settings.IntroStepUpDown:
                            return qsTr("To move up or down, swipe vertically.")
                        case Settings.IntroStepScroll:
                            switch (gesturePad.scrollCounter) {
                            case 0:
                                return qsTr("To scroll through lists keep holding after swiping.")
                            case 1:
                                return qsTr("You've scrolled 1 time, keep holding to scroll another 9 times.")
                            default:
                                return qsTr("You've scrolled %1 times, keep holding to scroll another %2 times.").arg(
                                            gesturePad.scrollCounter).arg(
                                            10 - gesturePad.scrollCounter)
                            }
                        case Settings.IntroStepClick:
                            return qsTr("To select an item, tap anywhere on the pad.")
                        case Settings.IntroStepColors:
                            return qsTr("Pro tip: The color buttons at the bottom simulate an infrared remote.")
                        case Settings.IntroStepExit:
                            return qsTr("Tap the pad to finish the tutorial.")
                        }
                        return ""
                    }
                }

                Row {
                    opacity: settings.introStep < Settings.IntroStepDone ? 0 : 1
                    visible: isPortrait
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 500
                        }
                    }
                    anchors.centerIn: parent
                    spacing: appWindow.smallestScreen ? Theme.paddingMedium : appWindow.smallScreen ? 25 : 50

                    IconButton {
                        id: referenceIcon
                        icon.source: "image://theme/icon-m-image"
                        onClicked: {
                            if (settings.hapticsEnabled) {
                                rumbleEffect.start(2)
                            }

                            kodi.switchToWindow(Kodi.GuiWindowPictures)
                        }
                    }
                    IconButton {
                        icon.source: "image://theme/icon-m-music"
                        onClicked: {
                            if (settings.hapticsEnabled) {
                                rumbleEffect.start(2)
                            }

                            kodi.switchToWindow(Kodi.GuiWindowMusic)
                        }
                    }
                    IconButton {
                        icon.source: "image://theme/icon-m-home"
                        onClicked: {
                            if (settings.hapticsEnabled) {
                                rumbleEffect.start(2)
                            }

                            keys.home()
                        }
                    }
                    IconButton {
                        icon.source: "image://theme/icon-m-video"
                        onClicked: {
                            if (settings.hapticsEnabled) {
                                rumbleEffect.start(2)
                            }

                            kodi.switchToWindow(Kodi.GuiWindowVideos)
                        }
                    }
                    IconButton {
                        icon.source: "../icons/icon-m-tv.png"
                        icon.height: referenceIcon.icon.height
                        icon.width: referenceIcon.icon.width
                        onClicked: {
                            if (settings.hapticsEnabled) {
                                rumbleEffect.start(2)
                            }

                            kodi.switchToWindow(Kodi.GuiWindowLiveTV)
                        }
                        layer.effect: ShaderEffect {
                            property color color: Theme.primaryColor

                            fragmentShader: "
                                varying mediump vec2 qt_TexCoord0;
                                uniform highp float qt_Opacity;
                                uniform lowp sampler2D source;
                                uniform highp vec4 color;
                                void main() {
                                highp vec4 pixelColor = texture2D(source, qt_TexCoord0);
                                gl_FragColor = vec4(mix(pixelColor.rgb/max(pixelColor.a, 0.00390625), color.rgb/max(color.a, 0.00390625), color.a) * pixelColor.a, pixelColor.a) * qt_Opacity;
                                }
                            "
                        }
                        layer.enabled: true
                        layer.samplerName: "source"
                    }
                }
            }

            Rectangle {
                // Just create some space
                visible: isLandscape
                height: Theme.paddingMedium
                color: "transparent"
                width: height
            }

            GesturePad {
                id: gesturePad
                width: isPortrait ? (appWindow.bigScreen ? parent.width
                                                           * 0.75 : parent.width) : parent.width / 2
                anchors.horizontalCenter: isPortrait ? parent.horizontalCenter : undefined

                IconButton {
                    id: backButton
                    opacity: settings.introStep < Settings.IntroStepDone ? 0 : 1
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 500
                        }
                    }
                    icon.source: "image://theme/icon-m-back"
                    anchors {
                        left: parent.left
                        top: parent.top
                        margins: Theme.paddingMedium
                    }
                    onClicked: {
                        if (settings.hapticsEnabled) {
                            rumbleEffect.start(2)
                        }
                        keys.back()
                    }
                }
                IconButton {
                    opacity: settings.introStep < Settings.IntroStepDone ? 0 : 1
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 500
                        }
                    }
                    icon.source: usePictureControls ? "image://theme/icon-m-add" : "image://theme/icon-m-back"
                    rotation: usePictureControls ? 0 : 135
                    anchors {
                        right: parent.right
                        top: parent.top
                        margins: Theme.paddingMedium
                    }
                    onClicked: {
                        if (settings.hapticsEnabled) {
                            rumbleEffect.start(2)
                        }

                        if (usePictureControls) {
                            picturePlayer.zoomIn()
                        } else {
                            keys.fullscreen()
                        }
                    }
                }
                IconButton {
                    opacity: settings.introStep < Settings.IntroStepDone ? 0 : 1
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 500
                        }
                    }
                    icon.source: usePictureControls ? "image://theme/icon-m-refresh" : "image://theme/icon-m-about"
                    anchors {
                        left: parent.left
                        bottom: parent.bottom
                        margins: Theme.paddingMedium
                    }
                    onClicked: {
                        if (settings.hapticsEnabled) {
                            rumbleEffect.start(2)
                        }

                        if (usePictureControls) {
                            picturePlayer.rotate()
                        } else {
                            keys.info()
                        }
                    }
                    onPressAndHold: {
                        if (settings.hapticsEnabled) {
                            rumbleEffect.start(2)
                        }

                        if (!usePictureControls) {
                            keys.procinfo()
                        }
                    }
                }
                IconButton {
                    opacity: settings.introStep < Settings.IntroStepDone ? 0 : 1
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 500
                        }
                    }
                    icon.source: usePictureControls ? "image://theme/icon-m-remove" : "image://theme/icon-m-menu"
                    icon.height: backButton.icon.height
                    icon.width: backButton.icon.width
                    anchors {
                        right: parent.right
                        bottom: parent.bottom
                        margins: Theme.paddingMedium
                    }
                    onClicked: {
                        if (settings.hapticsEnabled) {
                            rumbleEffect.start(2)
                        }

                        if (usePictureControls) {
                            picturePlayer.zoomOut()
                        } else {
                            keys.osd()
                            keys.contextMenu()
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                color: "transparent"
                border.color: Theme.rgba(Theme.highlightColor,
                                         Theme.highlightBackgroundOpacity)
                border.width: 2
                radius: 10
                height: Theme.itemSizeMedium
                visible: isPortrait

                Row {
                    anchors.centerIn: parent
                    spacing: parent.width / 8
                    opacity: settings.introStep < Settings.IntroStepColors ? 0 : 1
                    visible: isPortrait
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 500
                        }
                    }

                    Rectangle {
                        visible: !usePictureControls
                        height: 20 * appWindow.sizeRatio
                        width: parent.spacing
                        color: "red"
                        anchors.verticalCenter: parent.verticalCenter
                        radius: 2
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -10
                            onClicked: {
                                if (settings.hapticsEnabled) {
                                    rumbleEffect.start(2)
                                }

                                if (settings.introStep < Settings.IntroStepDone) {
                                    introLabel2.text = qsTr(
                                                "Remote name: %1<br>Button name: %2").arg(
                                                "kodimote").arg("red")
                                    settings.introStep = Settings.IntroStepExit
                                }
                                keys.red()
                            }
                        }
                    }
                    IconButton {
                        visible: usePictureControls
                        opacity: settings.introStep < Settings.IntroStepDone ? 0 : 1
                        Behavior on opacity {
                            NumberAnimation {
                                duration: 500
                            }
                        }
                        icon.source: "image://theme/icon-m-repeat"
                        onClicked: {
                            if (settings.hapticsEnabled) {
                                rumbleEffect.start(2)
                            }
                            picturePlayer.playPause()
                        }
                    }
                    Rectangle {
                        visible: !usePictureControls
                        height: 20 * appWindow.sizeRatio
                        width: parent.spacing
                        color: "green"
                        anchors.verticalCenter: parent.verticalCenter
                        radius: 2
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -10
                            onClicked: {
                                if (settings.hapticsEnabled) {
                                    rumbleEffect.start(2)
                                }

                                if (settings.introStep < Settings.IntroStepDone) {
                                    introLabel2.text = qsTr(
                                                "Remote name: %1<br>Button name: %2").arg(
                                                "kodimote").arg("green")
                                    settings.introStep = Settings.IntroStepExit
                                }
                                keys.green()
                            }
                        }
                    }
                    Rectangle {
                        visible: !usePictureControls
                        height: 20 * appWindow.sizeRatio
                        width: parent.spacing
                        color: "yellow"
                        anchors.verticalCenter: parent.verticalCenter
                        radius: 2
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -10
                            onClicked: {
                                if (settings.hapticsEnabled) {
                                    rumbleEffect.start(2)
                                }

                                if (settings.introStep < Settings.IntroStepDone) {
                                    introLabel2.text = qsTr(
                                                "Remote name: %1<br>Button name: %2").arg(
                                                "kodimote").arg("yellow")
                                    settings.introStep = Settings.IntroStepExit
                                }
                                keys.yellow()
                            }
                        }
                    }
                    Rectangle {
                        visible: !usePictureControls
                        height: 20 * appWindow.sizeRatio
                        width: parent.spacing
                        color: "blue"
                        anchors.verticalCenter: parent.verticalCenter
                        radius: 2
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -10
                            onClicked: {
                                if (settings.hapticsEnabled) {
                                    rumbleEffect.start(2)
                                }

                                if (settings.introStep < Settings.IntroStepDone) {
                                    introLabel2.text = qsTr(
                                                "Remote name: %1<br>Button name: %2").arg(
                                                "kodimote").arg("blue")
                                    settings.introStep = Settings.IntroStepExit
                                }
                                keys.blue()
                            }
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                color: Theme.rgba(Theme.highlightBackgroundColor,
                                  Theme.highlightBackgroundOpacity)
                height: Theme.itemSizeMedium
                visible: settings.introStep < Settings.IntroStepDone
                Label {
                    id: introLabel2
                    anchors {
                        fill: parent
                        leftMargin: Theme.paddingSmall
                        rightMargin: Theme.paddingSmall
                    }
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: "white"
                    wrapMode: Text.WordWrap
                    text: {
                        switch (settings.introStep) {
                        case Settings.IntroStepScroll:
                            return qsTr("The further you move, the faster you scroll.")
                        case Settings.IntroStepColors:
                            return qsTr("You can map them to anything you want in Kodi's Lircmap.xml")
                        }
                        return ""
                    }
                    opacity: settings.introStep < Settings.IntroStepDone ? 1 : 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 500
                        }
                    }
                }
            }
        }
        Rectangle {
            width: 2 * Theme.itemSizeMedium + Theme.paddingLarge
            color: "transparent"
            visible: isLandscape
            anchors.left: column.right
            anchors.top: parent.top
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: -parent.width / 2.5

            Label {
                anchors {
                    fill: parent
                    leftMargin: Theme.paddingSmall
                    rightMargin: Theme.paddingSmall
                }
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WordWrap
                opacity: settings.introStep < Settings.IntroStepDone ? 1 : 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: 500
                    }
                }
                color: "white"
                text: {
                    switch (settings.introStep) {
                    case Settings.IntroStepLeftRight:
                        return qsTr("To move left or right, swipe horizontally anywhere on the pad.")
                    case Settings.IntroStepUpDown:
                        return qsTr("To move up or down, swipe vertically.")
                    case Settings.IntroStepScroll:
                        switch (gesturePad.scrollCounter) {
                        case 0:
                            return qsTr("To scroll through lists keep holding after swiping.")
                        case 1:
                            return qsTr("You've scrolled 1 time, keep holding to scroll another 9 times.")
                        default:
                            return qsTr("You've scrolled %1 times, keep holding to scroll another %2 times.").arg(
                                        gesturePad.scrollCounter).arg(
                                        10 - gesturePad.scrollCounter)
                        }
                    case Settings.IntroStepClick:
                        return qsTr("To select an item, tap anywhere on the pad.")
                    case Settings.IntroStepColors:
                        return qsTr("Pro tip: The color buttons at the bottom simulate an infrared remote.")
                    case Settings.IntroStepExit:
                        return qsTr("Tap the pad to finish the tutorial.")
                    }
                    return ""
                }
            }

            Column {
                opacity: settings.introStep < Settings.IntroStepDone ? 0 : 1
                visible: isLandscape
                Behavior on opacity {
                    NumberAnimation {
                        duration: 500
                    }
                }
                anchors.centerIn: parent
                spacing: appWindow.bigScreen ? 50 : 20

                Row {
                    IconButton {
                        id: referenceIcon_landscape
                        icon.source: "image://theme/icon-m-image"
                        onClicked: {
                            if (settings.hapticsEnabled) {
                                rumbleEffect.start(2)
                            }
                            kodi.switchToWindow(Kodi.GuiWindowPictures)
                        }
                    }
                    IconButton {
                        icon.source: "image://theme/icon-m-music"
                        onClicked: {
                            if (settings.hapticsEnabled) {
                                rumbleEffect.start(2)
                            }
                            kodi.switchToWindow(Kodi.GuiWindowMusic)
                        }
                    }
                }
                Row {
                    IconButton {
                        icon.source: "image://theme/icon-m-home"
                        onClicked: {
                            if (settings.hapticsEnabled) {
                                rumbleEffect.start(2)
                            }
                            keys.home()
                        }
                    }
                    IconButton {
                        icon.source: "image://theme/icon-m-video"
                        onClicked: {
                            if (settings.hapticsEnabled) {
                                rumbleEffect.start(2)
                            }
                            kodi.switchToWindow(Kodi.GuiWindowVideos)
                        }
                    }
                }
                IconButton {
                    icon.source: "../icons/icon-m-tv.png"
                    icon.height: referenceIcon_landscape.icon.height
                    icon.width: referenceIcon_landscape.icon.width
                    onClicked: {
                        if (settings.hapticsEnabled) {
                            rumbleEffect.start(2)
                        }
                        kodi.switchToWindow(Kodi.GuiWindowLiveTV)
                    }
                    layer.effect: ShaderEffect {
                        property color color: Theme.primaryColor

                        fragmentShader: "
                            varying mediump vec2 qt_TexCoord0;
                            uniform highp float qt_Opacity;
                            uniform lowp sampler2D source;
                            uniform highp vec4 color;
                            void main() {
                            highp vec4 pixelColor = texture2D(source, qt_TexCoord0);
                            gl_FragColor = vec4(mix(pixelColor.rgb/max(pixelColor.a, 0.00390625), color.rgb/max(color.a, 0.00390625), color.a) * pixelColor.a, pixelColor.a) * qt_Opacity;
                            }
                        "
                    }
                    layer.enabled: true
                    layer.samplerName: "source"
                }
            }
        }
        Rectangle {
            width: Theme.itemSizeMedium + Theme.paddingLarge
            height: colorButton.height
            color: "transparent"
            anchors.verticalCenter: parent.verticalCenter
            visible: isLandscape
            anchors.top: parent.top
            anchors.topMargin: bigScreen ? Theme.paddingLarge : Theme.paddingMedium
            anchors.rightMargin: Theme.paddingLarge
            anchors.right: parent.right

            Column {
                id: colorButton
                anchors.centerIn: parent
                spacing: parent.height / 6
                opacity: settings.introStep < Settings.IntroStepColors ? 0 : 1
                visible: isLandscape
                Behavior on opacity {
                    NumberAnimation {
                        duration: 500
                    }
                }

                Rectangle {
                    visible: !usePictureControls
                    height: 20 * appWindow.sizeRatio
                    width: parent.spacing
                    color: "red"
                    radius: 2
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -10
                        onClicked: {
                            if (settings.hapticsEnabled) {
                                rumbleEffect.start(2)
                            }

                            if (settings.introStep < Settings.IntroStepDone) {
                                introLabel2.text = qsTr(
                                            "Remote name: %1<br>Button name: %2").arg(
                                            "kodimote").arg("red")
                                settings.introStep = Settings.IntroStepExit
                            }
                            keys.red()
                        }
                    }
                }
                IconButton {
                    visible: usePictureControls
                    opacity: settings.introStep < Settings.IntroStepDone ? 0 : 1
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 500
                        }
                    }
                    icon.source: "image://theme/icon-m-repeat"
                    onClicked: {
                        if (settings.hapticsEnabled) {
                            rumbleEffect.start(2)
                        }
                        picturePlayer.playPause()
                    }
                }
                Rectangle {
                    visible: !usePictureControls
                    height: 20 * appWindow.sizeRatio
                    width: parent.spacing
                    color: "green"
                    radius: 2
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -10
                        onClicked: {
                            if (settings.hapticsEnabled) {
                                rumbleEffect.start(2)
                            }

                            if (settings.introStep < Settings.IntroStepDone) {
                                introLabel2.text = qsTr(
                                            "Remote name: %1<br>Button name: %2").arg(
                                            "kodimote").arg("green")
                                settings.introStep = Settings.IntroStepExit
                            }
                            keys.green()
                        }
                    }
                }
                Rectangle {
                    visible: !usePictureControls
                    height: 20 * appWindow.sizeRatio
                    width: parent.spacing
                    color: "yellow"
                    radius: 2
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -10
                        onClicked: {
                            if (settings.hapticsEnabled) {
                                rumbleEffect.start(2)
                            }

                            if (settings.introStep < Settings.IntroStepDone) {
                                introLabel2.text = qsTr(
                                            "Remote name: %1<br>Button name: %2").arg(
                                            "kodimote").arg("yellow")
                                settings.introStep = Settings.IntroStepExit
                            }
                            keys.yellow()
                        }
                    }
                }
                Rectangle {
                    visible: !usePictureControls
                    height: 20 * appWindow.sizeRatio
                    width: parent.spacing
                    color: "blue"
                    radius: 2
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -10
                        onClicked: {
                            if (settings.hapticsEnabled) {
                                rumbleEffect.start(2)
                            }

                            if (settings.introStep < Settings.IntroStepDone) {
                                introLabel2.text = qsTr(
                                            "Remote name: %1<br>Button name: %2").arg(
                                            "kodimote").arg("blue")
                                settings.introStep = Settings.IntroStepExit
                            }
                            keys.blue()
                        }
                    }
                }
            }
        }
    }
}
