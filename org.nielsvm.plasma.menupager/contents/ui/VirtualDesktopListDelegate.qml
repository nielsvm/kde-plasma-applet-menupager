/*
 *  SPDX-FileCopyrightText: 2024 Niels <niels@nielsvm.org>
 *  SPDX-License-Identifier: GPL-3.0-only
 */

import QtQuick 2.2
import QtQuick.Layouts 1.1
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as Components

Item {
    id: item
    signal clicked()

    property alias text: label.text
    property bool interactive: true
    readonly property bool containsMouse: area.containsMouse
    property Item highlight

    implicitHeight: row.implicitHeight + 2 * Kirigami.Units.largeSpacing
    implicitWidth: row.implicitWidth
    Layout.fillWidth: true

    MouseArea {
        id: area
        anchors.fill: parent
        enabled: item.interactive
        hoverEnabled: true
        onClicked: item.clicked()
        onContainsMouseChanged: {
            if (!highlight) {
                return
            }
            if (containsMouse) {
                highlight.parent = item
            }
        }
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        width: parent.width - 2 * Kirigami.Units.largeSpacing
        spacing: Kirigami.Units.largeSpacing

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            Components.Label {
                id: label
                Layout.fillWidth: true
                wrapMode: Text.NoWrap
                elide: Text.ElideRight
            }
        }
    }
}
