//
//  SavePasteApp.swift
//  SavePaste
//
//  Created by Arnaud LE BOURBLANC on 03/04/2022.
//

import SwiftUI

@main
struct SavePasteApp: App {
    let persistenceController = PersistenceController.shared

    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            EmptyView().frame(width: .zero)
        }
    }
}
