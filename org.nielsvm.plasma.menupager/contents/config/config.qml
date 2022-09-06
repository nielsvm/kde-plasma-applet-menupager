/*
 *  SPDX-FileCopyrightText: 2022 Niels <niels@nielsvm.org>
 *  SPDX-License-Identifier: GPL-3.0-only
 */

import QtQuick 2.0

import org.kde.plasma.configuration 2.0

ConfigModel {
    ConfigCategory {
         name: i18n("General")
         icon: "preferences-desktop-plasma"
         source: "configGeneral.qml"
    }
}