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

Page {
    id: youTubePage
    allowedOrientations: appWindow.bigScreen ? Orientation.Portrait | Orientation.Landscape
                                               | Orientation.LandscapeInverted : Orientation.Portrait

    SilicaFlickable {
        id: flickable
        anchors.fill: parent

        Column {
            id: column
            width: parent.width
            PageHeader {
                title: qsTr("YouTube")
            }
            SectionHeader {
                text: qsTr("YouTube URL")
            }
            TextField {
                id: youtubeUrl
                x: Theme.paddingLarge
                y: Theme.paddingLarge
                font.pixelSize: Theme.fontSizeMedium
                placeholderText: qsTr('Enter YouTube URL')
                text: Clipboard.text
                width: column.width - (2 * Theme.paddingLarge)
                EnterKey.enabled: text.trim().length > 0
                // EnterKey.onClicked: {
                //     protocolManager.execute(youtubeUrl.text)
                //     pageStack.pop()
                // }
            }
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Play")
                enabled: youtubeUrl.text.trim().length > 0
                onClicked: {
                    protocolManager.execute(youtubeUrl.text)
                    pageStack.pop()
                }
            }
        }
    }
}
