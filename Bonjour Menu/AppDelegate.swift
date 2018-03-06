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
class AppDelegate: NSObject, NSApplicationDelegate, NetServiceBrowserDelegate, NetServiceDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    let statusMenu = NSMenu()
    let statusIcon = NSImage(named: .statusIcon)

    var netservices = [NetService]();
    
    var netServiceToOpen: NetService?
    
    let netServiceBrowser = NetServiceBrowser()
    
    @IBOutlet weak var window: NSWindow!

    func applicationWillFinishLaunching(_ notification: Notification) {
        statusItem.menu = statusMenu
        statusItem.image = statusIcon
        updateMenu()
        
        netServiceBrowser.delegate = self
        netServiceBrowser.searchForServices(ofType: "_postgresql._tcp", inDomain: "local.")
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        netservices.append(service)
        service.delegate = self
        if !moreComing { updateMenu() }
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        if let index = netservices.index(of: service) {
            netservices.remove(at: index)
        }
        if !moreComing { updateMenu() }
    }
    
    func updateMenu() {
        statusMenu.removeAllItems()
        
        if netservices.isEmpty {
            let loadingItem = NSMenuItem(title: "No Services Found", action: nil, keyEquivalent: "")
            statusMenu.addItem(loadingItem)
        } else {
            for service in netservices {
                statusMenu.addItem(withTitle: service.name, action: #selector(AppDelegate.connectToService(_:)), keyEquivalent: "")
            }
        }
        statusMenu.addItem(NSMenuItem.separator())
        let quitItem = NSMenuItem(title: "Quit Bonjour Menu", action: #selector(NSApplication.terminate), keyEquivalent: "")
        statusMenu.addItem(quitItem)
    }
    
    @objc func connectToService(_ sender: NSMenuItem) {
        let service = netservices[sender.menu!.index(of: sender)]
        netServiceToOpen = service
        service.delegate = self
        service.resolve(withTimeout: 3)
    }
    
    func netServiceDidResolveAddress(_ sender: NetService) {
        guard netServiceToOpen == sender else { return }
        guard let hostname = sender.hostName?.trimmingCharacters(in: CharacterSet(charactersIn: ".")) else { NSSound.beep(); return }
        guard let url = URL(string:"postgresql://\(hostname):\(sender.port)?nickname=\(sender.name.addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed)!)") else { NSSound.beep(); return }
        print(url)
        NSWorkspace.shared.open(url)
    }
    
    func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
        guard netServiceToOpen == sender else { return }
        NSSound.beep()
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

