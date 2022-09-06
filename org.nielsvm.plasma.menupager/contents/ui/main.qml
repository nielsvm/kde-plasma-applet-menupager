/*
 *  SPDX-FileCopyrightText: 2022 Niels <niels@nielsvm.org>
 *  SPDX-License-Identifier: GPL-3.0-only
 */

import QtQuick 2.15
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kquickcontrolsaddons 2.0 as KQuickControlsAddonsComponents
import org.kde.draganddrop 2.0
import org.kde.plasma.private.pager 2.0

Item {
    id: root
    Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation
    Plasmoid.status: pagerModel.shouldShowPager
                     ? PlasmaCore.Types.ActiveStatus
                     : PlasmaCore.Types.HiddenStatus

    function currentDesktopName() {
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

    function action_addDesktop() {
        pagerModel.addDesktop();
    }

    function action_removeDesktop() {
        pagerModel.removeDesktop();
    }

    function action_openKCM() {
        KQuickControlsAddonsComponents.KCMShell.open("kcm_kwin_virtualdesktops");
    }

    PagerModel {
        id: pagerModel
        enabled: root.visible
        screenGeometry: plasmoid.screenGeometry
    }

    /**
     * Panel label.
     */
    Plasmoid.compactRepresentation: Item {
        id: compactRoot

        readonly property bool isVertical:   Plasmoid.formFactor === PlasmaCore.Types.Vertical
        readonly property bool isSmall:      Plasmoid.formFactor === PlasmaCore.Types.Horizontal && Math.round(2 * (compactRoot.height / 5)) <= PlasmaCore.Theme.smallestFont.pixelSize
        readonly property int  widthFactor:  plasmoid.configuration.displayedLabel ? 4: 1
        readonly property int  widthMinimum: PlasmaCore.Theme.mSize(PlasmaCore.Theme.defaultFont).height * widthFactor

        Layout.minimumWidth: isVertical ? 0 : (label.implicitWidth < widthMinimum ? widthMinimum : label.implicitWidth)
        Layout.maximumWidth: isVertical ? Infinity : Layout.minimumWidth
        Layout.preferredWidth: isVertical ? -1 : Layout.minimumWidth
        Layout.minimumHeight: isVertical ? label.height : PlasmaCore.Theme.smallestFont.pixelSize
        Layout.maximumHeight: isVertical ? Layout.minimumHeight : Infinity
        Layout.preferredHeight: isVertical ? Layout.minimumHeight : PlasmaCore.Theme.mSize(PlasmaCore.Theme.defaultFont).height * 2

        PlasmaComponents3.Label {
            id: label
            height: compactRoot.height
            text: format(currentDesktopName())
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.NoWrap
            fontSizeMode: Text.VerticalFit
            minimumPointSize: PlasmaCore.Theme.smallestFont.pointSize
            font.pixelSize: isSmall ? PlasmaCore.Theme.defaultFont.pixelSize : PlasmaCore.Units.roundToIconSize(PlasmaCore.Units.gridUnit * 2)
            anchors.fill: parent
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent

            property int wheelDelta: 0

            onClicked: {
                if (plasmoid.configuration.menuOnClick) {
                    plasmoid.expanded = !plasmoid.expanded
                }
                else {
                    plasmoid.expanded = false
                }
            }

            onWheel: {
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
    Plasmoid.fullRepresentation: Item {
        implicitHeight: column.implicitHeight
        implicitWidth: column.implicitWidth

        Layout.preferredWidth: PlasmaCore.Units.gridUnit * 12
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
                    onClicked: {
                        plasmoid.expanded = false;
                        pagerModel.changePage(index);
                    }
                }
            }
        }
    }

    Connections {
        target: plasmoid.configuration
        onFormatBoldChanged: {
            pagerModel.refresh();
        }
        onFormatItalicChanged: {
            pagerModel.refresh();
        }
        onFormatUnderlineChanged: {
            pagerModel.refresh();
        }
        onSwitchOnScrollChanged: {
            pagerModel.refresh();
        }
        onDisplayedLabelChanged: {
            pagerModel.refresh();
        }
    }

    Component.onCompleted: {
        if (KQuickControlsAddonsComponents.KCMShell.authorize("kcm_kwin_virtualdesktops.desktop").length > 0) {
            plasmoid.setAction("addDesktop", i18n("Add Virtual Desktop"), "list-add");
            plasmoid.setAction("removeDesktop", i18n("Remove Virtual Desktop"), "list-remove");
            plasmoid.action("removeDesktop").enabled = Qt.binding(function() {
                return pagerModel.count > 1;
            });
            plasmoid.setAction("openKCM", i18n("Configure Virtual Desktops..."), "configure");
        }
    }
}
