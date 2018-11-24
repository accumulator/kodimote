/*****************************************************************************
 * Copyright: 2011-2013 Michael Zanetti <michael_zanetti@gmx.net>            *
 *            2014      Robert Meijers <robert.meijers@gmail.com>            *
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

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components/"
import harbour.kodimote 1.0

Page {
    id: nowPlayingPage

    property QtObject player: kodi.activePlayer
    property QtObject playlist: player ? player.playlist() : null
    property QtObject currentItem: player ? player.currentItem : null
    property bool timerActive: (( Qt.application.active && nowPlayingPage.status == PageStatus.Active ) ||
    cover.status === Cover.Active) && cover.status !== Cover.Deactivating

    onPlayerChanged: {
        if(player === null) {
            //pop immediately to prevent the empty page being shown during the pop animation
            //pageStack.pop(undefined, PageStackAction.Immediate);
        }
    }

    onStatusChanged: {
        if (status === PageStatus.Active) {
            pageStack.pushAttached(Qt.resolvedUrl("PlaylistPage.qml"));
        }
    }

    onTimerActiveChanged: { player.timerActive = timerActive }

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
            }

            Thumbnail {
                artworkSource: currentItem ? currentItem.thumbnail : ""
                width: parent.width
                height: artworkSize && artworkSize.width > artworkSize.height ? artworkSize.height / (artworkSize.width / width) : appWindow.mediumScreen || appWindow.largeScreen ? 900 : appWindow.smallScreen ? 648 : 400
                fillMode: Image.PreserveAspectFit
                smooth: true
                defaultText: currentItem ? currentItem.title : ""

                MouseArea {
                    anchors.fill: parent
                    onClicked: drawer.open = !drawer.open
                }
            }

            // create some space between thumbnail and title
            Item{
                width: parent.width
                height: Theme.paddingLarge

                MouseArea {
                    anchors.fill: parent
                    onClicked: drawer.open = !drawer.open
                }
            }

            Item {
                height: titleLabel.height
                anchors.left: parent.left
                anchors.right: parent.right
                Label {
                    id: titleLabel
                    anchors {
                        left: parent.left
                        right: playlistItemLabel.left
                        rightMargin: Theme.paddingMedium
                    }
                    font {
                        bold: true
                        family: Theme.fontFamilyHeading
                    }
                    truncationMode: TruncationMode.Fade
                    text: currentItem ? currentItem.title : ""

                    MouseArea {
                        anchors.fill: parent
                        onClicked: drawer.open = !drawer.open
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
                visible: text.length > 0
                font {
                    family: Theme.fontFamilyHeading
                    bold: true
                }
            }

            Label {
                text: currentItem.album
                width: parent.width
                truncationMode: TruncationMode.Fade
                visible: text.length > 0
                font.bold: true
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
                id: drawer
                backgroundSize: itemDetails.height
                property real backgroundHeight: itemDetails.height * drawer._progress

                background: NowPlayingDetails {
                    id: itemDetails

                    width: parent.width
                }

                height: Math.max(playerColumn.height,backgroundHeight)
                width: parent.width

                Column {
                    id: playerColumn
                    width: parent.width

                    ProgressBar {
                        id: progressBar
                        width: parent.width
                        leftMargin: 0
                        rightMargin: 0

                        minimumValue: 0
                        maximumValue: 100
                        value: player ? player.percentage : 0
                        // Why is the progressbar position lower in light ambiences?
                        height: appWindow.isLightTheme ? Theme.paddingLarge * 4 : Theme.paddingLarge * 3

                        Label {
                            anchors.left: parent.left
                            anchors.bottom: parent.bottom
                            color: Theme.highlightColor
                            font.pixelSize: appWindow.smallScreen ? Theme.fontSizeExtraSmall : Theme.fontSizeSmall
                            text: player ? player.timeString : "00:00"
                        }

                        Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            color: Theme.secondaryHighlightColor
                            font.pixelSize: appWindow.smallScreen ? Theme.fontSizeExtraSmall : Theme.fontSizeSmall
                            text: "[" + qsTr("ends at ") + player.endTimeString + "]"
                        }

                        Label {
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            color: Theme.highlightColor
                            font.pixelSize: appWindow.smallScreen ? Theme.fontSizeExtraSmall : Theme.fontSizeSmall
                            text: player.totalTimeString
                        }

                        Rectangle {
                            color: Theme.primaryColor
                            rotation: 45
                            width: 10 * appWindow.sizeRatio
                            height: 10 * appWindow.sizeRatio
                            anchors.horizontalCenter: progressBarLabel.horizontalCenter
                            anchors.verticalCenter: progressBarLabel.bottom
                            visible: progressBarLabel.visible
                        }

                        Rectangle {
                            id: progressBarLabel
                            color: Theme.primaryColor
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: (Theme.paddingLarge * 2) + Theme.fontSizeSmall
                            height: appWindow.sizeRatio * 40
                            width: progressBarLabelText.width + 20
                            radius: 5
                            visible: progressBarMouseArea.pressed

                            Label {
                                id: progressBarLabelText
                                anchors.centerIn: parent
                                color: Theme.secondaryHighlightColor
                            }
                        }

                        MouseArea {
                            id: progressBarMouseArea
                            height: Theme.paddingLarge
                            width: parent.width
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: Theme.fontSizeSmall
                            preventStealing: true

                            onMouseXChanged: {
                                // Center label on mouseX
                                progressBarLabel.x = mouseX - progressBarLabel.width / 2;

                                progressBarLabelText.text = player.calculateTimeString(mouseX * 100 / width);
                            }

                            onReleased: {
                                player.seek(mouseX * 100 / width)
                            }
                        }
                    }
                }

                states: [
                    State {
                        when: drawer.opened
                        PropertyChanges { target: playlistItemLabel; opacity: 0 }
                    }
                ]
            }
        }
    }
}
