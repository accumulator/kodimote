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
import "../"

CoverBackground {
    id: cover
    property QtObject player: kodi.activePlayer
    property QtObject currentItem: player ? player.currentItem : null
    property bool hasThumbnail: cover.currentItem && cover.currentItem.thumbnail.length
    property bool timerActive: cover.status === PageStatus.Active

    onTimerActiveChanged: {
        player.timerActive = timerActive
    }

    function addHost() {
        pageStack.completeAnimation()
        appWindow.activate()
        appWindow.addHost()
    }

    function browseMusic() {
        pageStack.completeAnimation()
        appWindow.activate()
        appWindow.showMedia("music")
    }

    function browseVideo() {
        pageStack.completeAnimation()
        appWindow.activate()
        appWindow.showMedia("video")
    }

    function connectToHost() {
        pageStack.clear()
        pageStack.completeAnimation()
        appWindow.activate()
        appWindow.showConnect()
    }

    function playPause() {
        cover.player.playPause()
    }

    function stop() {
        cover.player.stop()
    }

    Image {
        source: "./background.png"
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: sourceSize.height * (parent.width / sourceSize.width)
        fillMode: Image.PreserveAspectFit
    }

    Image {
        id: thumbnail
        width: cover.hasThumbnail > 0 ? parent.width - 2*Theme.paddingLarge : 80

        anchors.top: parent.top
        anchors.bottom: desc_col.top
        anchors.topMargin: Theme.paddingLarge
        anchors.bottomMargin: Theme.paddingMedium
        anchors.horizontalCenter: parent.horizontalCenter

        visible: cover.hasThumbnail
        source: cover.hasThumbnail > 0 ? cover.currentItem.thumbnail : ""
        fillMode: Image.PreserveAspectFit
    }

    Column {
        id: desc_col
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - 2 * Theme.paddingLarge
        anchors.top: parent.top
        anchors.topMargin: thumbnail.visible ? (subdescription.text !== "" ? parent.height / 2  : parent.height / 1.8 ) : parent.height / 3
        spacing: 0

        Label {
            id: description
            color: Theme.primaryColor
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            width: parent.width
            fontSizeMode: Text.HorizontalFit
            minimumPixelSize: subdescription.text === "" ? (20 * appWindow.sizeRatio) : -1
            height: thumbnail.visible && lineCount > 2 ? 2 * font.pixelSize : lineCount * font.pixelSize
            elide: thumbnail.visible && lineCount > 2 ? Text.ElideRight : Text.ElideNone
        }

        Label {
            id: subdescription
            color: Theme.primaryColor
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            fontSizeMode: Text.HorizontalFit
            width: parent.width
            height: lineCount * font.pixelSize
        }
    }

    Item {
        id: progBar
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        anchors.top: parent.top
        anchors.topMargin: parent.height / 1.6
        height: Theme.paddingLarge
        ProgressBar {
            width: parent.width
            minimumValue: 0
            maximumValue: 100
            value: cover.player ? cover.player.percentage : 0
            visible: cover.player && !appWindow.bigScreen
        }
    }
    Label {
        id: elapsed
        anchors.top: progBar.bottom
        width: parent.width
        anchors.topMargin: Theme.paddingSmall
        horizontalAlignment: Text.AlignHCenter
        color: Theme.highlightColor
        font.pixelSize: Theme.fontSizeSmall
        text: player ? player.timeString  + " - " + player.totalTimeString : "00:00"
        visible: cover.player
    }

    CoverActionList {
        id: actions

        CoverAction {
            id: leftAction
        }

        CoverAction {
            id: rightAction
        }
    }

    states: [
        State {
            when: cover.player && (cover.player.state === "playing" || cover.player.state === "paused")
            PropertyChanges {
                target: description
                text: cover.currentItem ? cover.currentItem.title : ""
            }
            PropertyChanges {
                target: subdescription
                text: cover.currentItem ? cover.currentItem.subtitle : ""
            }
            PropertyChanges {
                target: leftAction
                iconSource: "image://theme/icon-cover-" + (cover.player && cover.player.state === "playing" ? "pause" : "play")
                onTriggered: playPause()
            }
            PropertyChanges {
                target: rightAction
                iconSource: "../icons/icon-cover-stop.png"
                onTriggered: stop()
            }
        },
        State {
            when: kodi.connected
            PropertyChanges {
                target: description
                text: qsTr("Kodi on") + "\n" + kodi.connectedHostName
            }
            PropertyChanges {
                target: leftAction
                iconSource: "image://theme/icon-l-music"
                onTriggered: browseMusic()
            }
            PropertyChanges {
                target: rightAction
                iconSource: "image://theme/icon-l-video"
                onTriggered: browseVideo()
            }
        },
        State {
            when: !kodi.connected
            PropertyChanges {
                target: description
                text: qsTr("Kodimote") + "\n" +
                      qsTr("Disconnected")
            }
            PropertyChanges {
                target: leftAction
                iconSource: "image://theme/icon-cover-new"
                onTriggered: addHost()
            }
            PropertyChanges {
                target: rightAction
                iconSource: "image://theme/icon-cover-search"
                onTriggered: connectToHost()
            }
        }
    ]
}
