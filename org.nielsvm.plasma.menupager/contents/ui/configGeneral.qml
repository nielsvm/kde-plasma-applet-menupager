/*
 *  SPDX-FileCopyrightText: 2024 Niels <niels@nielsvm.org>
 *  SPDX-License-Identifier: GPL-3.0-only
 */

import QtQuick 2.5
import QtQuick.Controls 2.5 as QQC2

import org.kde.kirigami 2.5 as Kirigami
import org.kde.plasma.plasmoid 2.0
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    property int   cfg_displayedLabel
    property alias cfg_formatBold:      formatBoldCheck.checked
    property alias cfg_formatItalic:    formatItalicCheck.checked
    property alias cfg_formatUnderline: formatUnderlineCheck.checked
    property alias cfg_switchOnScroll:  switchOnScrollCheck.checked
    property alias cfg_menuOnClick:     menuOnClickCheck.checked

    Kirigami.FormLayout {

        /**
         * Behavior.
         */
        Item {
            Kirigami.FormData.isSection: true
        }
        QQC2.CheckBox {
            id: switchOnScrollCheck
            Kirigami.FormData.label: i18n("Behavior:")
            text: i18n("Switch desktops with mouse wheel")
        }
        QQC2.CheckBox {
            id: menuOnClickCheck
            text: i18n("Show menu on click")
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
            checked: cfg_displayedLabel === 0
            onToggled: if (checked) cfg_displayedLabel = 0;
        }
        QQC2.RadioButton {
            id: desktopNameRadio
            QQC2.ButtonGroup.group: displayedLabelGroup
            text: i18n("Desktop name")
            checked: cfg_displayedLabel === 1
            onToggled: if (checked) cfg_displayedLabel = 1;
        }

        /**
         * Formatting.
         */
        Item {
            Kirigami.FormData.isSection: true
        }
        QQC2.CheckBox {
            id: formatBoldCheck
            Kirigami.FormData.label: i18n("Font style:")
            text: i18n("Bold")
        }
        QQC2.CheckBox {
            id: formatItalicCheck
            text: i18n("Italic")
        }
        QQC2.CheckBox {
            id: formatUnderlineCheck
            text: i18n("Underline")
        }
    }
}