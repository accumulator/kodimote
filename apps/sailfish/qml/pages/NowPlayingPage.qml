

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
import QtQuick 2.2
import Sailfish.Silica 1.0
import harbour.kodimote 1.0
import "../components/"

Page {
    id: nowPlayingPage
    allowedOrientations: appWindow.orientationSetting

    property QtObject player: kodi.activePlayer
    property QtObject playlist: player ? player.playlist() : null
    property QtObject currentItem: player ? player.currentItem : null
    property bool timerActive: ((Qt.application.active
                                 && nowPlayingPage.status === PageStatus.Active)
                                || cover.status === Cover.Active)
                               && cover.status !== Cover.Deactivating

    onPlayerChanged: {
        if (player === null) {

            //pop immediately to prevent the empty page being shown during the pop animation
            //pageStack.pop(undefined, PageStackAction.Immediate);
        }
    }

    onStatusChanged: {
        if (status === PageStatus.Active) {
            pageStack.pushAttached(Qt.resolvedUrl("PlaylistPage.qml"))
        }
    }

    onTimerActiveChanged: {
        player.timerActive = timerActive
    }

    SilicaFlickable {
        anchors.fill: parent
        // Tell SilicaFlickable the height of its content.
        contentHeight: column.height

        VerticalScrollDecorator {
        }

        PullDownMenu {
            visible: kodi.activePlayer
            ControlsMenuItem {
            }
            MenuItem {
                text: qsTr("Play YouTube URL")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("YouTubeSendPage.qml"))
                }
            }
        }

        Column {
            id: column
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Theme.paddingLarge

            // create space to display thumbnail below navigation bullets
            PageHeader {
                title: qsTr("Now Playing")
                visible: isPortrait || appWindow.bigScreen
            }

            // Some space on top when header is not shown
            Item {
                visible: isLandscape && !appWindow.bigScreen
                width: parent.width
                height: Theme.paddingLarge
            }

            Row {
                width: column.width
                Thumbnail {
                    id: thumb
                    artworkSource: currentItem ? currentItem.thumbnail : ""
                    width: isPortrait ? parent.width : parent.width / 2
                    height: artworkSize
                            && artworkSize.width > artworkSize.height ? artworkSize.height / (artworkSize.width / width) : appWindow.mediumScreen || appWindow.largeScreen ? 900 : appWindow.smallScreen ? 648 : 400
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    defaultText: currentItem ? currentItem.title : ""

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            drawer.open = !drawer.open
                            drawer_landscape.open = !drawer_landscape.open
                        }
                    }
                }
                Column {
                    visible: isLandscape
                    spacing: Theme.paddingMedium
                    width: parent.width
                    Label {
                        width: parent.width / 2
                        horizontalAlignment: Text.AlignRight
                        id: titleLabel_landscape
                        font {
                            family: Theme.fontFamilyHeading
                        }
                        wrapMode: Text.Wrap
                        text: currentItem ? currentItem.title : ""

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                drawer.open = !drawer.open
                                drawer_landscape.open = !drawer_landscape.open
                            }
                        }
                    }

                    Label {
                        width: parent.width / 2
                        id: playlistItemLabel_landscape
                        horizontalAlignment: Text.AlignRight
                        truncationMode: TruncationMode.Fade
                        text: playlist ? playlist.currentTrackNumber + "/" + playlist.count : "0/0"

                        Behavior on opacity {
                            NumberAnimation {
                                property: "opacity"
                                duration: 300
                                easing.type: Easing.InOutQuad
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: pageStack.navigateForward()
                        }
                    }
                    Label {
                        text: currentItem.subtitle
                        horizontalAlignment: Text.AlignRight
                        width: parent.width / 2
                        wrapMode: Text.Wrap
                        color: Theme.highlightColor
                        visible: text.length > 0
                        font {
                            family: Theme.fontFamilyHeading
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                drawer.open = !drawer.open
                                drawer_landscape.open = !drawer_landscape.open
                            }
                        }
                    }

                    Label {
                        text: currentItem.album
                        horizontalAlignment: Text.AlignRight
                        width: parent.width / 2
                        wrapMode: Text.Wrap
                        visible: text.length > 0
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                drawer.open = !drawer.open
                                drawer_landscape.open = !drawer_landscape.open
                            }
                        }
                    }

                    ItemDetailRow {
                        visible: currentItem.season > -1
                        title: qsTr("Season:")
                        text: currentItem.season
                    }

                    ItemDetailRow {
                        visible: currentItem.episode > -1
                        title: qsTr("Episode:")
                        text: currentItem.episode
                    }
                    Drawer {
                        id: drawer_landscape
                        backgroundSize: itemDetails_landscape.height
                        property real backgroundHeight: itemDetails_landscape.height
                                                        * drawer_landscape._progress

                        background: NowPlayingDetails {
                            id: itemDetails_landscape
                            width: parent.width / 2
                            x: Theme.paddingMedium
                        }

                        height: Math.max(playerColumn_landscape.height,
                                         backgroundHeight) - 30
                        width: parent.width

                        Column {
                            id: playerColumn_landscape
                            width: parent.width / 2

                            Slider {
                                id: progressBar_landscape

                                handleVisible: false
                                label: {
                                    "-" + player.remainingTimeString + "/" + player.totalTimeString
                                            + " (" + player.percentage.toFixed(
                                                0) + "%, " + qsTr(
                                                "ends at ") + player.endTimeString + ")"
                                }
                                value: progressBar.value
                                minimumValue: 0
                                maximumValue: 100

                                valueText: down ? player.calculateTimeString(
                                                      value) : player ? player.timeString : "00:00"
                                width: parent.width

                                onReleased: {
                                    player.seek(value)
                                    // rebind the value, else it no longer updates
                                    value = Qt.binding(function () {
                                        return progressBar.value
                                    })
                                }
                            }
                        }

                        states: [
                            State {
                                when: drawer_landscape.opened
                                PropertyChanges {
                                    target: playlistItemLabel
                                    opacity: 0
                                }
                            }
                        ]
                    }
                }
            }

            // create some space between thumbnail and title
            Item {
                width: parent.width
                height: Theme.paddingLarge

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        drawer.open = !drawer.open
                        drawer_landscape.open = !drawer_landscape.open
                    }
                }
            }

            Item {
                height: titleLabel.height
                anchors.left: parent.left
                anchors.right: parent.right
                visible: isPortrait
                Label {
                    id: titleLabel
                    anchors {
                        left: parent.left
                        right: playlistItemLabel.left
                        rightMargin: Theme.paddingMedium
                    }
                    font {
                        family: Theme.fontFamilyHeading
                    }
                    truncationMode: TruncationMode.Fade
                    text: currentItem ? currentItem.title : ""

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            drawer.open = !drawer.open
                            drawer_landscape.open = !drawer_landscape.open
                        }
                    }
                }

                Label {
                    id: playlistItemLabel
                    anchors.right: parent.right
                    truncationMode: TruncationMode.Fade
                    text: playlist ? playlist.currentTrackNumber + "/" + playlist.count : "0/0"

                    Behavior on opacity {
                        NumberAnimation {
                            property: "opacity"
                            duration: 300
                            easing.type: Easing.InOutQuad
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: pageStack.navigateForward()
                    }
                }
            }

            Label {
                text: currentItem.subtitle
                width: parent.width
                truncationMode: TruncationMode.Fade
                color: Theme.highlightColor
                visible: text.length > 0 && isPortrait
                font {
                    family: Theme.fontFamilyHeading
                }
            }

            Label {
                text: currentItem.album
                width: parent.width
                truncationMode: TruncationMode.Fade
                visible: text.length > 0 && isPortrait
            }

            ItemDetailRow {
                visible: currentItem.season > -1 && isPortrait
                title: qsTr("Season:")
                text: currentItem.season
            }

            ItemDetailRow {
                visible: currentItem.episode > -1 && isPortrait
                title: qsTr("Episode:")
                text: currentItem.episode
            }
            Drawer {
                id: drawer
                visible: isPortrait
                backgroundSize: itemDetails.height
                property real backgroundHeight: itemDetails.height * drawer._progress + 30

                background: NowPlayingDetails {
                    id: itemDetails

                    width: parent.width
                }

                height: Math.max(playerColumn.height, backgroundHeight) - 30
                width: parent.width

                Column {
                    id: playerColumn
                    width: parent.width

                    Slider {
                        id: progressBar

                        handleVisible: false
                        label: {
                            "-" + player.remainingTimeString + "/" + player.totalTimeString
                                    + " (" + player.percentage.toFixed(
                                        0) + "%, " + qsTr(
                                        "ends at ") + player.endTimeString + ")"
                        }
                        value: player ? player.percentage : 0
                        minimumValue: 0
                        maximumValue: 100

                        valueText: down ? player.calculateTimeString(
                                              value) : player ? player.timeString : "00:00"
                        width: parent.width

                        onReleased: {
                            player.seek(value)
                            // rebind the value, else it no longer updates
                            value = Qt.binding(function () {
                                return player.percentage
                            })
                        }
                    }
                }

                states: [
                    State {
                        when: drawer.opened
                        PropertyChanges {
                            target: playlistItemLabel
                            opacity: 0
                        }
                    }
                ]
            }
        }
    }
}
