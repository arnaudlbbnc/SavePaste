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
        let savedPastes = PersistenceController.shared.getTexts()
        for savedPaste in savedPastes {
            createPasteMenuItem(parentMenu: savedsMenu, paste: savedPaste)
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

    private func createPasteMenuItem(parentMenu: NSMenu, paste: Paste) {
        let pasteMenu = NSMenu()

        let pasteItem = NSMenuItem()
        pasteItem.title = NSLocalizedString("actions.paste", comment: "")
        pasteItem.target = self
        pasteItem.action = #selector(paste(_:))
        pasteItem.representedObject = paste
        pasteMenu.addItem(pasteItem)

        let copyItem = NSMenuItem()
        copyItem.title = NSLocalizedString("actions.copy", comment: "")
        copyItem.target = self
        copyItem.action = #selector(copyToPasteboard(_:))
        copyItem.representedObject = paste
        pasteMenu.addItem(copyItem)

        let removeItem = NSMenuItem()
        removeItem.title = NSLocalizedString("actions.remove", comment: "")
        removeItem.target = self
        removeItem.action = #selector(removePaste(_:))
        removeItem.representedObject = paste
        pasteMenu.addItem(removeItem)


        let menuItem = NSMenuItem()
        menuItem.title = String(paste.text?.prefix(15) ?? "?")
        menuItem.target = self
        menuItem.action = #selector(paste(_:))
        menuItem.representedObject = paste
        menuItem.submenu = pasteMenu

        parentMenu.addItem(menuItem)
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

    @objc private func copyToPasteboard(_ sender: Any?) {
        guard let text = pasteFromMenuItem(sender)?.text else {
            return
        }

        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }

    @objc private func removePaste(_ sender: Any?) {
        guard let text = pasteFromMenuItem(sender)?.text else {
            return
        }

        PersistenceController.shared.removeText(text)
        createMenu()
    }

    @objc private func resetSaved() {
        PersistenceController.shared.resetTexts()
        createMenu()
    }

    @objc private func launchAtLogin(_ sender: Any?) {
        Preferences.launchAtLoginEnabled = !Preferences.launchAtLoginEnabled
        createMenu()
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }

    private func pasteFromMenuItem(_ menuItem: Any?) -> Paste? {
        guard let menuItem = menuItem as? NSMenuItem else {
            return nil
        }

        return menuItem.representedObject as? Paste

    }

    @objc private func paste(_ sender: Any?) {
        guard let text = pasteFromMenuItem(sender)?.text else {
            return
        }

        let currentPasteboard = getCurrentPasteboardDatas()

        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)

        let source = CGEventSource(stateID: CGEventSourceStateID.combinedSessionState);

        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 9, keyDown: true);
        keyDown?.flags = CGEventFlags.maskCommand;
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 9, keyDown: false);

        keyDown?.post(tap: .cgAnnotatedSessionEventTap)
        keyUp?.post(tap: .cgAnnotatedSessionEventTap)

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [weak self] in
            self?.setBackPasteboardData(pasteboard: currentPasteboard)
        }
    }

    private func getCurrentPasteboardDatas() -> [(type: NSPasteboard.PasteboardType, data: Data)] {
        guard let types = NSPasteboard.general.types else {
            return []
        }

        var currentPasteboard: [(type: NSPasteboard.PasteboardType, data: Data)] = []
        for type in types {
            if let data = NSPasteboard.general.data(forType: type) {
                currentPasteboard.append((type, data))
            }
        }
        return currentPasteboard
    }

    private func setBackPasteboardData(pasteboard: [(type: NSPasteboard.PasteboardType, data: Data)]) {
        for (type, data) in pasteboard {
            NSPasteboard.general.setData(data, forType: type)
        }
    }
}
