

/*****************************************************************************
 * Copyright: 2011-2013 Michael Zanetti <michael_zanetti@gmx.net>            *
 *            2014      Robert Meijers <robert.meijers@gmail.com>            *
 *            2017      Sander van Grieken <sander@outrightsolutions.nl>     *
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
import QtQuick 2.2
import Sailfish.Silica 1.0
import QtFeedback 5.0
import harbour.kodimote 1.0

Row {
    id: playerControls

    property QtObject player
    spacing: (appWindow.mediumScreen
              || appWindow.largeScreen) ? Theme.paddingLarge : appWindow.smallScreen ? Theme.paddingMedium : Theme.paddingSmall
    property int iconResize: appWindow.largeScreen ? 160 : appWindow.mediumScreen ? 128 : appWindow.smallScreen ? 100 : 75

    HapticsEffect {
        id: rumbleEffect
        intensity: 0.50
        duration: 50
    }

    IconButton {
        id: referenceIcon
        icon.source: "image://theme/icon-m-previous"
        icon.height: iconResize
        icon.width: iconResize
        height: iconResize
        width: iconResize
        enabled: !!player
        onClicked: {
            if (settings.hapticsEnabled) {
                rumbleEffect.start(2)
            }
            playerControls.player.skipPrevious()
        }
    }

    IconButton {
        icon.source: "../icons/icon-m-backward.png"
        icon.height: iconResize
        icon.width: iconResize
        height: iconResize
        width: iconResize
        enabled: player ? player.state == "playing"
                          && player.type !== Player.PlayerTypePictures : false
        onClicked: {
            if (settings.hapticsEnabled) {
                rumbleEffect.start(2)
            }
            playerControls.player.seekBackward()
        }
        highlighted: down || (playerControls.player
                              && playerControls.player.speed < 0)
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

    IconButton {
        icon.source: "../icons/icon-m-stop.png"
        icon.height: iconResize
        icon.width: iconResize
        height: iconResize
        width: iconResize
        enabled: player ? player.state !== "stopped" : false
        onClicked: {
            if (settings.hapticsEnabled) {
                rumbleEffect.start(2)
            }
            playerControls.player.stop()
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

    IconButton {
        icon.source: "image://theme/icon-" + (appWindow.largeScreen ? "l-" : "m-")
                     + (player && player.speed === 1
                        && player.state === "playing" ? "pause" : "play")
        icon.height: iconResize
        icon.width: iconResize
        height: iconResize
        width: iconResize
        enabled: !!player
        onClicked: {
            if (settings.hapticsEnabled) {
                rumbleEffect.start(2)
            }
            playerControls.player.playPause()
        }
    }

    IconButton {
        icon.source: "../icons/icon-m-forward.png"
        icon.height: iconResize
        icon.width: iconResize
        height: iconResize
        width: iconResize
        enabled: player ? player.state === "playing"
                          && player.type !== Player.PlayerTypePictures : false
        onClicked: {
            if (settings.hapticsEnabled) {
                rumbleEffect.start(2)
            }
            playerControls.player.seekForward()
        }
        highlighted: down || (playerControls.player
                              && playerControls.player.speed > 1)
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

    IconButton {
        icon.source: "image://theme/icon-m-next"
        icon.height: iconResize
        icon.width: iconResize
        height: iconResize
        width: iconResize
        enabled: !!player
        onClicked: {
            if (settings.hapticsEnabled) {
                rumbleEffect.start(2)
            }
            playerControls.player.skipNext()
        }
    }
}
