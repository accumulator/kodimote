/*****************************************************************************
 * Copyright: 2011-2013 Michael Zanetti <michael_zanetti@gmx.net>            *
 *                                                                           *
 * This file is part of Kodimote                                           *
 *                                                                           *
 * Kodimote is free software: you can redistribute it and/or modify        *
 * it under the terms of the GNU General Public License as published by      *
 * the Free Software Foundation, either version 3 of the License, or         *
 * (at your option) any later version.                                       *
 *                                                                           *
 * Kodimote is distributed in the hope that it will be useful,             *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of            *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             *
 * GNU General Public License for more details.                              *
 *                                                                           *
 * You should have received a copy of the GNU General Public License         *
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.     *
 *                                                                           *
 ****************************************************************************/

import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.Components.ListItems 1.3
import Kodi 1.0
import "components"

KodiPage {
    id: root
    title: qsTr("Now Playing")

    property QtObject player: kodi.activePlayer
    property QtObject playlist: player ? player.playlist() : null
    property QtObject currentItem: player ? player.currentItem : null

    property string orientation: width > height ? "landscape" : "portrait"

    property int spacing: units.gu(1)

    onPlayerChanged: {
        if(player !== null) {
            player.timerActive = timerActive
        }
    }

    property bool timerActive: false

    onTimerActiveChanged: {
        print("timer is now", timerActive)
        player.timerActive = timerActive
    }


   Connections {
       target: kodi
       onStateChanged: {
           print("!*!*! state:", kodi.state);
       }
   }

    Component.onCompleted: {
        console.log("player is " + player)
        console.log("playlist is " + playlist)
    }

    Label {
        anchors.centerIn: parent
        width: parent.width - units.gu(4)
        text: qsTr("No active playback. Please select some content from the media tab.")
        wrapMode: Text.WordWrap
        fontSize: "large"
        opacity: root.player == null ? 1 : 0
        visible: opacity > 0
        horizontalAlignment: Text.AlignHCenter

        Behavior on opacity {
            UbuntuNumberAnimation {}
        }
    }

    Item {
        anchors.fill: parent
        anchors.bottomMargin: bottomEdge.height
        anchors.topMargin: root.header.height
        opacity: root.player !== null ? 1 : 0
        visible: opacity > 0
        Behavior on opacity {
            UbuntuNumberAnimation {}
        }

        ListView {
            id: playlistView
            anchors {
                left: parent.left
                top: parent.top
                right: parent.right
            }
            height: showPlaylist ? parent.height - units.gu(8) : 0
            property bool showPlaylist: false
            clip: true
            Behavior on height {
                UbuntuNumberAnimation {}
            }

            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0, 0, 0, 0.3)
            }

            model: playlist
            delegate: ListItem {
                id: playlistDelegate

                leadingActions: ListItemActions {
                    actions: [
                        Action {
                            iconName: "delete"
                            onTriggered: playlist.removeItem(index)
                        }
                    ]
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: units.gu(1)

                    Label {
                        Layout.fillWidth: true
                        text: title
                        elide: Text.ElideRight
                        font.bold: index == playlist.currentTrackNumber - 1
                    }
                    Label {
                        text: duration
                        font.bold: index == playlist.currentTrackNumber - 1
                    }
                }
                onClicked: {
                    player.playItem(index);
                }
                onPressAndHold: {
                    PopupUtils.open(playlistPopoverComponent, playlistDelegate, {selectedIndex: index})
                }
            }
        }

        MouseArea {
            anchors {
                left: parent.left
                right: parent.right
                top: playlistView.bottom
                bottom: parent.bottom
            }
            enabled: playlistView.showPlaylist
            onClicked: playlistView.showPlaylist = false

            z: 2
        }

        GridLayout {
            id: mainGrid
            anchors {
                left: parent.left
                right: parent.right
                top: playlistView.bottom
                leftMargin: appWindow.pageMargins
                rightMargin: appWindow.pageMargins
                topMargin: appWindow.pageMargins
            }
            height: parent.height - appWindow.pageMargins * 2

            columns: root.orientation == "portrait" ? 1 : 2
            columnSpacing: appWindow.pageMargins
            rowSpacing: appWindow.pageMargins
            opacity: playlistView.showPlaylist ? .6 : 1
            Behavior on opacity { UbuntuNumberAnimation {} }

            Item {
                id: imageItem
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumWidth: parent.width / 2
//                height: root.orientation == "portrait" ? Math.min(parent.width, parent.height - textItem.height - parent.spacing) : parent.height
//                width: root.orientation == "portrait" ? parent.width : height

                LazyImage {
                    id: imageShape
                    anchors.fill: parent
                    opacity: 1
                    source: currentItem && currentItem.thumbnail ? "file://" + currentItem.thumbnail : ""
                    initialWidth: parent.width
                    initialHeight: parent.height
                    scaleTo: "fit"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: playlistView.showPlaylist = true
                    }
                }
            }

            ColumnLayout {
                id: textItem
                Layout.fillWidth: true
                Layout.fillHeight: true
//                width: root.orientation == "portrait" ? parent.width : parent.width - imageItem.width - parent.spacing
                spacing: root.spacing
                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: root.spacing
                    Label {
                        id: trackLabel
                        Layout.fillWidth: true
                        text: currentItem ? currentItem.title : ""
                        elide: Text.ElideRight
                        font.bold: true
                    }
                    Label {
                        id: trackNumLabel
                        text: playlist ? playlist.currentTrackNumber + "/" + playlist.count : "0/0"
                    }
                }
                Label {
                    id: artistLabel
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    text: !currentItem ? "" : (kodi.state === "audio" ? currentItem.artist : (currentItem.type == "episode" ? currentItem.tvShow : qsTr("Year:") + " " + currentItem.year))
                }
                RowLayout {
                    id: albumRow
                    Layout.preferredHeight: albumLabel.height
                    Layout.fillWidth: true
                    spacing: units.gu(.5)
                    Label {
                        id: albumLabel
                        elide: Text.ElideRight
                        text: !currentItem ? "" : (kodi.state === "audio" ? currentItem.album : (currentItem.type === "episode" ? qsTr("Season:") + " " + currentItem.season + "   " + qsTr("Episode:") + " " + currentItem.episode : qsTr("Rating:") + " "))
                    }
                    property int starCount: !currentItem ? 0 : (currentItem.rating > 10 ? Math.floor(currentItem.rating / 20) : Math.floor(currentItem.rating / 2))

                    RatingStars {
                        count: 5
                        rated: parent.starCount
                        height: albumLabel.height
                        visible: currentItem !== null && (currentItem.type === "movie" || currentItem.type === "unknown")
                    }
                }

                PlayerControls {
                    id: controlButtons
                    player: root.player
                    Layout.fillWidth: true
                }


                UbuntuShape {
                    id: progressBar
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.gu(1)
                    property int minimumValue: 0
                    property int maximumValue: 100
                    property int value: player ? player.percentage : 0

                    UbuntuShape {
                        anchors.fill: parent
                        anchors.rightMargin: parent.width - (parent.width * parent.value / 100)
                        backgroundColor: UbuntuColors.blue
                    }

                    Rectangle {
                        color: "white"
                        rotation: 45
                        width: units.gu(1.5)
                        height: width
                        anchors.horizontalCenter: progressBarLabel.horizontalCenter
                        anchors.verticalCenter: progressBarLabel.bottom
                        visible: progressBarLabel.visible
                    }

                    UbuntuShape {
                        id: progressBarLabel
                        backgroundColor: "white"
                        anchors.bottom: parent.top
                        anchors.bottomMargin: units.gu(3)
                        height: units.gu(6)
                        width: progressBarLabelText.width + 20
                        visible: progressBarMouseArea.pressed

                        Label {
                            id: progressBarLabelText
                            anchors.centerIn: parent
                            color: "black"
                        }
                    }

                    MouseArea {
                        id: progressBarMouseArea
                        anchors.fill: progressBar
                        anchors.topMargin: -root.spacing
                        anchors.bottomMargin: -root.spacing
                        preventStealing: true
                        property var targetTime

                        onPositionChanged: {
                            // Center label on mouseX
                            progressBarLabel.x = mouseX - progressBarLabel.width / 2;

                            progressBarLabelText.text = player.calculateTimeString(mouseX * 100 / width);
                            mouse.accepted = true
                        }
                        onReleased: {
                            player.seek(mouseX * 100 / width)
                        }
                    }
                }

                Row {
                    Layout.fillWidth: true
                    spacing: root.spacing
                    Label {
                        id: currentTime
                        text: player ? player.timeString : "00:00"
                        width: (parent.width - parent.spacing) / 2
                    }

                    Label {
                        text: player ? player.totalTimeString : ""
                        horizontalAlignment: Text.AlignRight
                        width: (parent.width - parent.spacing) / 2
                    }
                }
            }
        }
    }


    Component {
        id: toolbarMenuComponent
        Dialog {
            id: toolbarMenu

            property alias model: listView.model
            property alias currentIndex: listView.currentIndex
            property bool showClearButton: false

            signal accepted(int selectedIndex)

            Column {
                anchors {
                    left: parent.left
                    right: parent.right
                }
                ListView {
                    id: listView
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    height: contentHeight
                    model: toolbarMenuModel
                    interactive: false
                    delegate: Standard {
                        text: modelData
                        selected: listView.currentIndex == index
                        onClicked: {
                            toolbarMenu.accepted(index)
                            PopupUtils.close(toolbarMenu)
                        }
                    }
                }
                Standard {
                    text: qsTr("None")
                    visible: toolbarMenu.showClearButton
                    selected: listView.currentIndex == -1
                    onClicked: {
                        toolbarMenu.accepted(-1);
                        PopupUtils.close(toolbarMenu)
                    }
                }
            }
        }
    }

    Component {
        id: playlistPopoverComponent
        Popover {
            id: playlistPopover
            property int selectedIndex
            Column {
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }
                height: childrenRect.height

                Standard {
                    text: qsTr("Play")
                    onClicked: {
                        player.playItem(selectedIndex)
                        PopupUtils.close(playlistPopover)
                    }
                }
                Standard {
                    text: qsTr("Remove from playlist")
                    onClicked: {
                        playlist.removeItem(selectedIndex)
                        PopupUtils.close(playlistPopover)
                    }
                }
                Standard {
                    text: qsTr("Clear playlist")
                    onClicked: {
                        playlist.clear()
                        PopupUtils.close(playlistPopover)
                    }
                }
            }
        }
    }

    BottomEdge {
        id: bottomEdge

        BottomEdgeButton {
            text: qsTr("Repeat")
            Layout.fillWidth: true
            source: player && player.repeat === Player.RepeatNone ? "image://theme/media-playlist-repeat" :
                                                             player && player.repeat === Player.RepeatOne ? "../images/media-playlist-repeat-one.svg" :
                                                                                                 "../images/media-playlist-repeat-all.svg"
            visible: root.player && root.player.type === Player.PlayerTypeAudio
            onClicked: {
                if (player.repeat === Player.RepeatNone) {
                    player.repeat = Player.RepeatOne;
                } else if (player.repeat === Player.RepeatOne) {
                    player.repeat = Player.RepeatAll;
                } else {
                    player.repeat = Player.RepeatNone;
                }
            }

        }
        BottomEdgeButton {
            text: qsTr("Shuffle")
            Layout.fillWidth: true
            source: player && player.shuffle ? "../images/media-playlist-shuffle-active.svg" : "image://theme/media-playlist-shuffle"
            visible: root.player && root.player.type === Player.PlayerTypeAudio
            onClicked: {
                player.shuffle = ! player.shuffle
            }
        }
        BottomEdgeButton {
            text: qsTr("Subtitles")
            Layout.fillWidth: true
            source: "image://theme/message"
            visible: root.player && root.player.type === Player.PlayerTypeVideo
            onClicked: {
                var popup = PopupUtils.open(toolbarMenuComponent, root, {model: player.subtitles, currentIndex: player.currentSubtitle, title: qsTr("Select subtitle"), showClearButton: true})
                popup.accepted.connect(function(selectedIndex) {player.currentSubtitle = selectedIndex})
            }
            enabled: !(kodi.state === "video" && player.subtitles.length === 0)
        }
        BottomEdgeButton {
            text: qsTr("Audio track")
            source: "image://theme/audio-speakers-symbolic"
            visible: root.player && root.player.type === Player.PlayerTypeVideo
            Layout.fillWidth: true
            onClicked: {
                var popup = PopupUtils.open(toolbarMenuComponent, root, {model: player.audiostreams, currentIndex: player.currentAudiostream, title: qsTr("Select audio track")})
                popup.accepted.connect(function(selectedIndex) {player.currentAudiostream = selectedIndex})
            }
        }
    }
}
