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

        createSavedMenuItems(mainMenu: mainMenu)

        mainMenu.addItem(NSMenuItem.separator())

        createPinnedMenuItems(mainMenu: mainMenu)

        mainMenu.addItem(NSMenuItem.separator())

        createLaunchAtLoginMenuItem(mainMenu: mainMenu)

        mainMenu.addItem(NSMenuItem.separator())

        createQuitMenuItem(mainMenu: mainMenu)

        statusItem.menu = mainMenu
    }

    private func createSavedMenuItems(mainMenu: NSMenu) {
        let saveItem = NSMenuItem()
        saveItem.title = NSLocalizedString("actions.save", comment: "")
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
        resetSavedItem.title = NSLocalizedString("actions.clear", comment: "")
        resetSavedItem.target = self
        resetSavedItem.action = #selector(resetSaved)

        savedsMenu.addItem(resetSavedItem)

        let savedsMenuItem = NSMenuItem()
        savedsMenuItem.title = NSLocalizedString("list.saved", comment: "")
        savedsMenuItem.isEnabled = !savedPastes.isEmpty
        savedsMenuItem.submenu = savedsMenu

        mainMenu.addItem(savedsMenuItem)
    }

    private func createPinnedMenuItems(mainMenu: NSMenu) {
        let pinItem = NSMenuItem()
        pinItem.title = NSLocalizedString("actions.pin", comment: "")
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
        resetPinnedItem.title = NSLocalizedString("actions.clear", comment: "")
        resetPinnedItem.target = self
        resetPinnedItem.action = #selector(resetPinned)

        pinnedsMenu.addItem(resetPinnedItem)

        let pinnedsMenuItem = NSMenuItem()
        pinnedsMenuItem.title = NSLocalizedString("list.pinned", comment: "")
        pinnedsMenuItem.isEnabled = !pinnedPastes.isEmpty
        pinnedsMenuItem.submenu = pinnedsMenu

        mainMenu.addItem(pinnedsMenuItem)
    }

    private func createLaunchAtLoginMenuItem(mainMenu: NSMenu) {
        let launchAtLoginItem = NSMenuItem()
        launchAtLoginItem.title = NSLocalizedString("actions.launchAtLogin", comment: "")
        launchAtLoginItem.state = Preferences.launchAtLoginEnabled ? .on : .off
        launchAtLoginItem.target = self
        launchAtLoginItem.action = #selector(launchAtLogin(_:))

        mainMenu.addItem(launchAtLoginItem)
    }

    private func createQuitMenuItem(mainMenu: NSMenu) {
        let quitItem = NSMenuItem()
        quitItem.title = NSLocalizedString("actions.quit", comment: "")
        quitItem.target = self
        quitItem.action = #selector(quit)

        mainMenu.addItem(quitItem)
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
