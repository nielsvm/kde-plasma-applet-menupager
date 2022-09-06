/*
 *  SPDX-FileCopyrightText: 2022 Niels <niels@nielsvm.org>
 *  SPDX-License-Identifier: GPL-3.0-only
 */

import QtQuick 2.5
import QtQuick.Controls 2.5 as QQC2
import org.kde.kirigami 2.5 as Kirigami

Kirigami.FormLayout {
    anchors.left: parent.left
    anchors.right: parent.right

    property int   cfg_displayedLabel
    property alias cfg_formatBold:      formatBoldCheck.checked
    property alias cfg_formatItalic:    formatItalicCheck.checked
    property alias cfg_formatUnderline: formatUnderlineCheck.checked
    property alias cfg_switchOnScroll:  switchOnScrollCheck.checked
    property alias cfg_menuOnClick:     menuOnClickCheck.checked

    /**
     * Behavior.
     */
    Item {
        Kirigami.FormData.isSection: true
    }
    QQC2.CheckBox {
        id: switchOnScrollCheck
        Kirigami.FormData.label: i18nc("@title:label", "Behavior:")
        text: i18nc("@option:check", "Switch desktops with mouse wheel")
    }
    QQC2.CheckBox {
        id: menuOnClickCheck
        text: i18nc("@option:check", "Show menu on click")
    }

    /**
     * Text display.
     */
    Item {
        Kirigami.FormData.isSection: true
    }
    QQC2.ButtonGroup {
        id: displayedLabelGroup
    }
    QQC2.RadioButton {
        id: desktopNumberRadio
        Kirigami.FormData.label: i18n("Display:")
        QQC2.ButtonGroup.group: displayedLabelGroup
        text: i18n("Desktop number")
        onCheckedChanged: if (checked) cfg_displayedLabel = 0;
    }
    QQC2.RadioButton {
        id: desktopNameRadio
        QQC2.ButtonGroup.group: displayedLabelGroup
        text: i18n("Desktop name")
        onCheckedChanged: if (checked) cfg_displayedLabel = 1;
    }

    onCfg_displayedLabelChanged: {
        switch (cfg_displayedLabel) {
            case 0:
                displayedLabelGroup.checkedButton = desktopNumberRadio;
                break;
            default:
            case 1:
                displayedLabelGroup.checkedButton = desktopNameRadio;
                break;
        }
    }

    /**
     * Formatting.
     */
    Item {
        Kirigami.FormData.isSection: true
    }
    QQC2.CheckBox {
        id: formatBoldCheck
        Kirigami.FormData.label: i18nc("@title:label", "Font style:")
        text: i18nc("@option:check", "Bold")
    }
    QQC2.CheckBox {
        id: formatItalicCheck
        text: i18nc("@option:check", "Italic")
    }
    QQC2.CheckBox {
        id: formatUnderlineCheck
        text: i18nc("@option:check", "Underline")
    }

    Component.onCompleted: {
        cfg_displayedLabelChanged();
    }
}
