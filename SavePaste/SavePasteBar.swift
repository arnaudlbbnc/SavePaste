//
//  SavePasteBar.swift
//  SavePaste
//
//  Created by Arnaud LE BOURBLANC on 03/04/2022.
//

import AppKit
import Foundation

final class SavePasteBar: NSObject {
    private var statusBar: NSStatusBar
    private var statusItem: NSStatusItem

    override init() {
        statusBar = NSStatusBar.system
        statusItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)

        super.init()

        createMenu()
    }

    // MARK: - MenuConfig

    private func createMenu() {
        guard let statusBarButton = statusItem.button else {
            return
        }

        statusBarButton.image = NSImage(
            systemSymbolName: "doc.on.doc.fill",
            accessibilityDescription: nil
        )

        let mainMenu = NSMenu()

        let saveItem = NSMenuItem()
        saveItem.title = "Save from clipboard"
        saveItem.target = self
        saveItem.action = #selector(saveFromPasteboard)
        saveItem.isEnabled = NSPasteboard.general.string(forType: .string) != nil

        mainMenu.addItem(saveItem)

        let savedsMenu = NSMenu()
        let savedPastes = PersistenceController.shared.getTexts(pinned: false)
        for savedPaste in savedPastes {
            let savedMenuItem = NSMenuItem()
            savedMenuItem.title = String(savedPaste.text?.prefix(15) ?? "?")
            savedMenuItem.target = self
            savedMenuItem.action = #selector(copyToPasteboard(_:))
            savedMenuItem.representedObject = savedPaste
            savedsMenu.addItem(savedMenuItem)
        }

        savedsMenu.addItem(NSMenuItem.separator())

        let resetSavedItem = NSMenuItem()
        resetSavedItem.title = "Clear"
        resetSavedItem.target = self
        resetSavedItem.action = #selector(resetSaved)

        savedsMenu.addItem(resetSavedItem)

        let savedsMenuItem = NSMenuItem()
        savedsMenuItem.title = "Saved texts"
        savedsMenuItem.isEnabled = !savedPastes.isEmpty
        savedsMenuItem.submenu = savedsMenu

        mainMenu.addItem(savedsMenuItem)

        mainMenu.addItem(NSMenuItem.separator())

        let pinItem = NSMenuItem()
        pinItem.title = "Pin from clipboard"
        pinItem.target = self
        pinItem.action = #selector(pinFromPasteboard)
        pinItem.isEnabled = NSPasteboard.general.string(forType: .string) != nil

        mainMenu.addItem(pinItem)

        let pinnedsMenu = NSMenu()
        let pinnedPastes = PersistenceController.shared.getTexts(pinned: true)
        for pinnedPaste in pinnedPastes {
            let pinnedMenuItem = NSMenuItem()
            pinnedMenuItem.title = String(pinnedPaste.text?.prefix(15) ?? "?")
            pinnedMenuItem.target = self
            pinnedMenuItem.action = #selector(copyToPasteboard(_:))
            pinnedMenuItem.representedObject = pinnedPaste
            pinnedsMenu.addItem(pinnedMenuItem)
        }

        pinnedsMenu.addItem(NSMenuItem.separator())

        let resetPinnedItem = NSMenuItem()
        resetPinnedItem.title = "Clear"
        resetPinnedItem.target = self
        resetPinnedItem.action = #selector(resetPinned)

        pinnedsMenu.addItem(resetPinnedItem)

        let pinnedsMenuItem = NSMenuItem()
        pinnedsMenuItem.title = "Pinned texts"
        pinnedsMenuItem.isEnabled = !pinnedPastes.isEmpty
        pinnedsMenuItem.submenu = pinnedsMenu

        mainMenu.addItem(pinnedsMenuItem)

        mainMenu.addItem(NSMenuItem.separator())

        let launchAtLoginItem = NSMenuItem()
        launchAtLoginItem.title = "Launch at login"
        launchAtLoginItem.state = Preferences.launchAtLoginEnabled ? .on : .off
        launchAtLoginItem.target = self
        launchAtLoginItem.action = #selector(launchAtLogin(_:))

        mainMenu.addItem(launchAtLoginItem)

        mainMenu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem()
        quitItem.title = "Quit"
        quitItem.target = self
        quitItem.action = #selector(quit)

        mainMenu.addItem(quitItem)

        statusItem.menu = mainMenu
    }

    // MARK: - Actions
    @objc private func saveFromPasteboard() {
        guard let text = NSPasteboard.general.string(forType: .string) else {
            return
        }
        PersistenceController.shared.saveText(text)
        createMenu()
    }

    @objc private func pinFromPasteboard() {
        guard let text = NSPasteboard.general.string(forType: .string) else {
            return
        }
        PersistenceController.shared.saveText(text, pinned: true)
        createMenu()
    }

    @objc private func copyToPasteboard(_ sender: Any?) {
        guard let sender = sender as? NSMenuItem,
            let representedObject = sender.representedObject as? Paste,
            let text = representedObject.text else {
            return
        }

        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }

    @objc private func resetSaved() {
        PersistenceController.shared.resetTexts(pinned: false)
        createMenu()
    }

    @objc private func resetPinned() {
        PersistenceController.shared.resetTexts(pinned: true)
        createMenu()
    }

    @objc private func launchAtLogin(_ sender: Any?) {
        Preferences.launchAtLoginEnabled = !Preferences.launchAtLoginEnabled
        createMenu()
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}
