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

Dialog {

    property bool largeScreen: Screen.width > 540
    allowedOrientations: appWindow.orientationSetting

    SilicaFlickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: col.height

        VerticalScrollDecorator {
        }

        Column {
            id: col
            spacing: Theme.paddingMedium
            width: parent.width
            PageHeader {
                title: qsTr("About")
            }

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                source: isLandscape ? (largeScreen ? "/usr/share/icons/hicolor/256x256/apps/harbour-kodimote.png" : "/usr/share/icons/hicolor/86x86/apps/harbour-kodimote.png") : (largeScreen ? "/usr/share/icons/hicolor/256x256/apps/harbour-kodimote.png" : "/usr/share/icons/hicolor/128x128/apps/harbour-kodimote.png")
            }
            Label {
                text: "Kodimote " + version
                font.pixelSize: Theme.fontSizeExtraLarge
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Row {
                anchors.right: parent.right
                anchors.rightMargin: Theme.horizontalPageMargin
                anchors.left: parent.left
                anchors.leftMargin: Theme.horizontalPageMargin
                spacing: (width / 2) * 0.2
                Label {
                    text: "Michael Zanetti"
                    width: (parent.width / 2) * 0.95
                    font.pixelSize: Theme.fontSizeExtraSmall
                    font.underline: true
                    color: Theme.highlightColor
                    MouseArea {
                        anchors.fill : parent
                        onClicked: Qt.openUrlExternally("mailto:michael_zanetti@gmx.net?subject=Kodimote...")
                    }
                }
                Label {
                    text: "Robert Meijers"
                    width: (parent.width / 2) * 0.95
                    font.pixelSize: Theme.fontSizeExtraSmall
                    font.underline: true
                    color: Theme.highlightColor
                    MouseArea {
                        anchors.fill : parent
                        onClicked: Qt.openUrlExternally("mailto:robert.meijers@gmail.com?subject=Kodimote...")
                    }
                }
            }
            Row {
                anchors.right: parent.right
                anchors.rightMargin: Theme.horizontalPageMargin
                anchors.left: parent.left
                anchors.leftMargin: Theme.horizontalPageMargin
                spacing: (width / 2) * 0.2
                Label {
                    text: "Sander van Grieken"
                    font.pixelSize: Theme.fontSizeExtraSmall
                    font.underline: true
                    width: (parent.width / 2) * 0.95
                    color: Theme.highlightColor
                    MouseArea {
                        anchors.fill : parent
                        onClicked: Qt.openUrlExternally("mailto:sander@outrightsolutions.nl?subject=Kodimote...")
                    }
                }
                Label {
                    text: "Arno Dekker"
                    font.pixelSize: Theme.fontSizeExtraSmall
                    width: (parent.width / 2) * 0.95
                    color: Theme.highlightColor
                }
            }

            Label {
                id: gplLabel
                width: parent.width - Theme.paddingSmall
                wrapMode: Text.WordWrap
                x: Theme.paddingSmall
                font.pixelSize: Theme.fontSizeSmall * 0.75
                color: Theme.secondaryColor
                text: "This program is free software: you can redistribute it and/or modify " +
                "it under the terms of the GNU General Public License as published by " +
                "the Free Software Foundation, either version 3 of the License, or " +
                "(at your option) any later version.\n\n" +

                "This program is distributed in the hope that it will be useful, " +
                "but WITHOUT ANY WARRANTY; without even the implied warranty of " +
                "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the " +
                "GNU General Public License for more details.\n\n" +

                "You should have received a copy of the GNU General Public License " +
                "along with this program.  If not, see http://www.gnu.org/licenses/."
            }

            Row {
                anchors.right: parent.right
                anchors.rightMargin: Theme.horizontalPageMargin
                anchors.left: parent.left
                anchors.leftMargin: Theme.horizontalPageMargin
                spacing: (width / 2) * 0.1
                height: Theme.itemSizeMedium + Theme.paddingMedium
                Button {
                    id: donateButton
                    anchors.bottom: parent.bottom
                    width: (parent.width / 2) * 0.95
                    text: qsTr("Donate")
                    onClicked: Qt.openUrlExternally("https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=CWFYRZH8XNYF2")
                }
                Button {
                    anchors.bottom: parent.bottom
                    width: (parent.width / 2) * 0.95
                    text: qsTr("Flattr")
                    onClicked: Qt.openUrlExternally("http://flattr.com/thing/412274/Kodimote")
                }
            }
        }
    }
}
