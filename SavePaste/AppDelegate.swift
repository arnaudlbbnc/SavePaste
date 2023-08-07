//
//  AppDelegate.swift
//  SavePaste
//
//  Created by Arnaud LE BOURBLANC on 03/04/2022.
//

import Foundation
import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {

  private var savePasteBar: SavePasteBar?

  func applicationDidFinishLaunching(_ notification: Notification) {
      savePasteBar = .init()

      if let window = NSApplication.shared.windows.first {
          window.close()
      }
  }
}
