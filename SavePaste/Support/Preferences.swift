//
//  Preferences.swift
//  NootNootBar
//
//  Created by Arnaud Le Bourblanc on 02/06/2019.
//  Copyright © 2019 Arnaud Le Bourblanc. All rights reserved.
//

import Foundation

struct Preferences {

    private static var appURL: URL { Bundle.main.bundleURL }
    
    static var launchAtLoginEnabled: Bool {
        get { SharedFileList.sessionLoginItems().containsItem(appURL) }
        set {
            if newValue {
                SharedFileList.sessionLoginItems().addItem(appURL)
            } else {
                SharedFileList.sessionLoginItems().removeItem(appURL)
            }
        }
    }
}

enum PreferencesKey: String {
    case launchAtLogin
}
