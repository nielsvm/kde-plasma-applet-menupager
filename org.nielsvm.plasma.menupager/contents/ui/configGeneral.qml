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
    property int   cfg_displayWidth
    property int   cfg_fontSize
    property alias cfg_formatBold:      formatBoldCheck.checked
    property alias cfg_formatItalic:    formatItalicCheck.checked
    property alias cfg_formatUnderline: formatUnderlineCheck.checked
    property alias cfg_switchOnScroll:  switchOnScrollCheck.checked
    property alias cfg_menuOnClick:     menuOnClickCheck.checked

    Kirigami.FormLayout {

        /**
         * Behavior:
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
         * Display:
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
         * Display width:
         */
        Item {
            Kirigami.FormData.isSection: true
        }
        QQC2.ButtonGroup {
            id: displayWidthGroup
        }
        QQC2.RadioButton {
            id: displayWidthMinimumRadio
            Kirigami.FormData.label: i18n("Width:")
            QQC2.ButtonGroup.group: displayWidthGroup
            text: i18n("Minimum: as wide as desktop name")
            checked: cfg_displayWidth === 0
            onToggled: if (checked) cfg_displayWidth = 0;
        }
        QQC2.RadioButton {
            id: displayWidthSmallRadio
            QQC2.ButtonGroup.group: displayWidthGroup
            text: i18n("Small")
            checked: cfg_displayWidth === 1
            onToggled: if (checked) cfg_displayWidth = 1;
        }
        QQC2.RadioButton {
            id: displayWidthNormalRadio
            QQC2.ButtonGroup.group: displayWidthGroup
            text: i18n("Normal")
            checked: cfg_displayWidth === 2
            onToggled: if (checked) cfg_displayWidth = 2;
        }
        QQC2.RadioButton {
            id: displayWidthLargeRadio
            QQC2.ButtonGroup.group: displayWidthGroup
            text: i18n("Large")
            checked: cfg_displayWidth === 3
            onToggled: if (checked) cfg_displayWidth = 3;
        }

        /**
         * Font size:
         */
        Item {
            Kirigami.FormData.isSection: true
        }
        QQC2.ButtonGroup {
            id: fontSizeGroup
        }
        QQC2.RadioButton {
            id: fontSizeSmallRadio
            Kirigami.FormData.label: i18n("Font size:")
            QQC2.ButtonGroup.group: fontSizeGroup
            text: i18n("Small")
            checked: cfg_fontSize === 0
            onToggled: if (checked) cfg_fontSize = 0;
        }
        QQC2.RadioButton {
            id: fontSizeNormalRadio
            QQC2.ButtonGroup.group: fontSizeGroup
            text: i18n("Normal")
            checked: cfg_fontSize === 1
            onToggled: if (checked) cfg_fontSize = 1;
        }
        QQC2.RadioButton {
            id: fontSizeLargeRadio
            QQC2.ButtonGroup.group: fontSizeGroup
            text: i18n("Large")
            checked: cfg_fontSize === 2
            onToggled: if (checked) cfg_fontSize = 2;
        }

        /**
         * Font style:
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