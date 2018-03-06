//
//  AppDelegate.swift
//  Bonjour Menu
//
//  Created by Jakob Egger on 2018-03-06.
//  Copyright © 2018 Egger Apps. All rights reserved.
//

import Cocoa

extension NSImage.Name {
    static let statusIcon = NSImage.Name(rawValue:"StatusIcon")
}


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    let statusMenu = NSMenu()
    let statusIcon = NSImage(named: .statusIcon)

    @IBOutlet weak var window: NSWindow!

    func applicationWillFinishLaunching(_ notification: Notification) {
        statusItem.menu = statusMenu
        statusItem.image = statusIcon
        let loadingItem = NSMenuItem(title: "Searching...", action: nil, keyEquivalent: "")
        let quitItem = NSMenuItem(title: "Quit Bonjour Menu", action: #selector(NSApplication.terminate), keyEquivalent: "")
        statusMenu.addItem(loadingItem)
        statusMenu.addItem(quitItem)
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

