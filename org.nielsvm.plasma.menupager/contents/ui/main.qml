/*
 *  SPDX-FileCopyrightText: 2024 Niels <niels@nielsvm.org>
 *  SPDX-License-Identifier: GPL-3.0-only
 */

import QtQuick 2.15
import QtQuick.Layouts 1.1

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as Components
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kquickcontrolsaddons 2.0 as KQuickControlsAddonsComponents
import org.kde.draganddrop 2.0
import org.kde.plasma.private.pager 2.0
import org.kde.kirigami 2.20 as Kirigami

import org.kde.kcmutils as KCM
import org.kde.config as KConfig

PlasmoidItem {
    id: root
    preferredRepresentation: compactRepresentation
    Plasmoid.status: pagerModel.shouldShowPager
                     ? PlasmaCore.Types.ActiveStatus
                     : PlasmaCore.Types.HiddenStatus

    function getCurrentDesktopName() {
        if (!plasmoid.configuration.displayedLabel) {
            return pagerModel.currentPage+1;
        }
        var page = pagerModel.currentPage;
        if (!pagerModel.hasIndex(pagerModel.currentPage, 0)) {
            // When no index yet exists, it seems not possible to create it
            // with createIndex() and thus we return a fixed string as
            // temporary workaround.
            return i18n("Virtual Desktop");
        }
        return pagerModel.data(pagerModel.index(pagerModel.currentPage, 0), 0);
    }

    function getFontSize() {
        var factor = Kirigami.Units.gridUnit / 12;
        // Small
        if (plasmoid.configuration.fontSize == 0) {
            return factor * Kirigami.Theme.smallFont.pixelSize;
        }
        // Large
        else if (plasmoid.configuration.fontSize == 2) {
            return (factor*1.2) * Kirigami.Theme.defaultFont.pixelSize
        }
        // Normal
        else {
            return factor * Kirigami.Theme.defaultFont.pixelSize;
        }
    }

    function format(string) {
        var prefix = ""
        var suffix = ""
        if (plasmoid.configuration.formatBold) {
            prefix = '<b>' + prefix
            suffix = suffix + '</b>'
        }
        if (plasmoid.configuration.formatItalic) {
            prefix = '<i>' + prefix
            suffix = suffix + '</i>'
        }
        if (plasmoid.configuration.formatUnderline) {
            prefix = '<u>' + prefix
            suffix = suffix + '</u>'
        }
        return prefix + string + suffix
    }

    PagerModel {
        id: pagerModel
        enabled: root.visible
        screenGeometry: Plasmoid.containment.screenGeometry
    }

    /**
     * Panel label.
     */
    compactRepresentation: Item {
        id: compactRoot

        readonly property bool isVertical:   Plasmoid.formFactor === PlasmaCore.Types.Vertical
        readonly property bool isSmall:      Plasmoid.formFactor === PlasmaCore.Types.Horizontal && Math.round(2 * (compactRoot.height / 5)) <= Kirigami.Theme.smallFont.pixelSize
        readonly property int  widthFactor:  plasmoid.configuration.displayedLabel ? 10 : 3
        readonly property int  widthMinimum: widthFactor * Kirigami.Theme.defaultFont.pixelSize

        Layout.minimumWidth:    isVertical ? 0 : (label.implicitWidth < widthMinimum ? widthMinimum : label.implicitWidth)
        Layout.maximumWidth:    isVertical ? Infinity : Layout.minimumWidth
        Layout.preferredWidth:  isVertical ? -1 : Layout.minimumWidth
        Layout.minimumHeight:   isVertical ? label.height : Kirigami.Theme.smallFont.pixelSize
        Layout.maximumHeight:   isVertical ? Layout.minimumHeight : Infinity
        Layout.preferredHeight: isVertical ? Layout.minimumHeight : Kirigami.Theme.defaultFont.pixelSize * 2

        Components.Label {
            id: label
            anchors.fill: parent
            text: format(getCurrentDesktopName())
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.NoWrap

            // Logic borrowed from org.kde.plasma.digitalclock applet:
            minimumPixelSize: 1
            fontSizeMode: Text.VerticalFit
            font.family: Kirigami.Theme.defaultFont.family
            font.weight: Kirigami.Theme.defaultFont.weight
            font.italic: Kirigami.Theme.defaultFont.italic
            font.pixelSize: getFontSize()
            font.pointSize: -1
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            property int wheelDelta: 0

            onClicked: mouse => {
                if (plasmoid.configuration.menuOnClick) {
                    root.expanded = !root.expanded
                }
                else {
                    root.expanded = false
                }
            }

            onWheel: wheel => {
                if (!plasmoid.configuration.switchOnScroll) {
                    return;
                }

                // Magic number 120 for common "one click, see:
                // http://qt-project.org/doc/qt-5/qml-qtquick-wheelevent.html#angleDelta-prop
                wheelDelta += wheel.angleDelta.y || wheel.angleDelta.x;
                var increment = 0;
                while (wheelDelta >= 120) {
                    wheelDelta -= 120;
                    increment++;
                }
                while (wheelDelta <= -120) {
                    wheelDelta += 120;
                    increment--;
                }

                while (increment !== 0) {
                    if (increment < 0) {
                        const nextPage = Math.min(((pagerModel.currentPage == (pagerModel.count-1))
                                                    ? 0
                                                    : pagerModel.currentPage+1
                                                 ), pagerModel.count-1);
                        pagerModel.changePage(nextPage);
                    } else {
                        const previousPage = Math.max(((pagerModel.currentPage == 0)
                                                        ? pagerModel.count-1
                                                        : pagerModel.currentPage-1
                                                     ), 0);
                        pagerModel.changePage(previousPage);
                    }
                    increment += (increment < 0) ? 1 : -1;
                }
            }
        }
    }

    /**
     * Non-panel version / popup menu.
     */
    fullRepresentation: Item {
        implicitHeight: column.implicitHeight
        implicitWidth: column.implicitWidth

        Layout.preferredWidth: Kirigami.Units.gridUnit * 12
        Layout.preferredHeight: implicitHeight
        Layout.minimumWidth: Layout.preferredWidth
        Layout.minimumHeight: Layout.preferredHeight
        Layout.maximumWidth: Layout.preferredWidth
        Layout.maximumHeight: Screen.height / 2

        property Item delegateHighlight: PlasmaExtras.Highlight {
            id: delegateHighlight
            parent: null
            width: parent ? parent.width : undefined
            height: parent ? parent.height : undefined
            hovered: parent && parent.containsMouse
            z: -1 // raise to prevent tinted font color.
        }

        ColumnLayout {
            id: column
            spacing: 0
            anchors.fill: parent

            Repeater {
                model: pagerModel

                VirtualDesktopListDelegate {
                    text: plasmoid.configuration.displayedLabel ? model.display : index + 1
                    highlight: delegateHighlight
                    visible: true
                    onClicked: mouse => {
                        root.expanded = false;
                        pagerModel.changePage(index);
                    }
                }
            }
        }
    }

    Connections {
        target: plasmoid.configuration
        function onFormatBoldChanged() {
            pagerModel.refresh();
        }
        function onFormatItalicChanged() {
            pagerModel.refresh();
        }
        function onFormatUnderlineChanged() {
            pagerModel.refresh();
        }
        function onSwitchOnScrollChanged() {
            pagerModel.refresh();
        }
        function onDisplayedLabelChanged() {
            pagerModel.refresh();
        }
        function onFontSizeChanged() {
            pagerModel.refresh();
        }
    }

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: i18n("Add Virtual Desktop")
            icon.name: "list-add"
            visible: KConfig.KAuthorized.authorize("kcm_kwin_virtualdesktops")
            onTriggered: pagerModel.addDesktop()
        },
        PlasmaCore.Action {
            text: i18n("Remove Virtual Desktop")
            icon.name: "list-remove"
            visible: KConfig.KAuthorized.authorize("kcm_kwin_virtualdesktops")
            enabled: pagerModel.count > 1
            onTriggered: pagerModel.removeDesktop()
        },
        PlasmaCore.Action {
            text: i18n("Configure Virtual Desktops…")
            visible: KConfig.KAuthorized.authorize("kcm_kwin_virtualdesktops")
            onTriggered: KCM.KCMLauncher.openSystemSettings("kcm_kwin_virtualdesktops")
        }
    ]
}
