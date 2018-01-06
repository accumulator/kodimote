/*****************************************************************************
 * Copyright: 2011-2013 Michael Zanetti <michael_zanetti@gmx.net>            *
 *            2014      Robert Meijers <robert.meijers@gmail.com>            *
 *            2015      Sander van Grieken <sander@outrightsolutions.nl>     *
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
import "../components/"

Page {
    id: playlistPage

    property bool bigScreen: Screen.sizeCategory === Screen.Large
                               || Screen.sizeCategory === Screen.ExtraLarge
    allowedOrientations: bigScreen ? Orientation.Portrait | Orientation.Landscape
                         | Orientation.LandscapeInverted : Orientation.Portrait
    property QtObject player: kodi.activePlayer
    property QtObject playlist: player.playlist()
    property bool largeScreen: screen.width > 540

    SilicaFlickable {
        id: flickable
        interactive: !listView.flicking
        pressDelay: 0
        anchors.fill: parent

        PullDownMenu {
            id: mainMenu

            ControlsMenuItem {

            }

            MenuItem {
                text: qsTr("Play YouTube URL")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("YouTubeSendPage.qml"))
                }
            }
            MenuItem {
                text: qsTr("Clear playlist")
                enabled: playlist.count > 0
                onClicked: {
                    clearRemorse.execute(qsTr("Clear playlist"), playlist.clear)
                }
                RemorsePopup {
                    id: clearRemorse
                }
            }
        }

        SilicaListView {
            id: listView

            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width
            model: playlist
            clip: true

            header: PageHeader {
                title: "Current Playlist" // playlist.title
            }

            delegate: ListItem {
                id: listItem

                width: parent.width
                contentHeight: Theme.itemSizeMedium

                onClicked: {
                    player.playItem(index);
                }

                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("Play")
                        onClicked: {
                            player.playItem(index)
                        }
                    }
                    MenuItem {
                        text: qsTr("Remove from playlist")
                        onClicked: {
                            playlist.removeItem(index)
                        }
                    }
                }

                Column {
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        right: durationLabel.left
                        leftMargin: Theme.paddingLarge
                    }

                    Label {
                        id: mainText
                        text: title
                        font.weight: Font.Bold
                        font.pixelSize: largeScreen ? 26*2 : 26
                        width: listView.width - durationLabel.width
                        truncationMode: TruncationMode.Fade
                        color: listItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                        states: [
                            State {
                                name: "highlighted"
                                when: index === listView.model.currentTrackNumber - 1
                                PropertyChanges {
                                    target: mainText
                                    color: Theme.highlightColor
                                }
                            }
                        ]
                    }

                    Label {
                        id: subText
                        text: subtitle ? subtitle : ""
                        font.weight: Font.Light
                        font.pixelSize: largeScreen ? 24*2 : 24
                        color: Theme.secondaryColor
                        width: listView.width - durationLabel.width
                        truncationMode: TruncationMode.Fade
                        visible: text != ""
                    }
                }

                Label {
                    id: durationLabel
                    text: duration
                    anchors {
                        right: parent.right
                        rightMargin: Theme.paddingLarge
                        verticalCenter: parent.verticalCenter
                    }
                }
            }

            VerticalScrollDecorator {  }
        }

    }
}
