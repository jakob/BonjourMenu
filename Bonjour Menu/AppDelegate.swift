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

    let serviceTypes = ["_postgresql._tcp.", "_http._tcp."]
    let serviceTypeNames = ["PostgreSQL", "Web Sites"]
    var serviceBrowsers = [NetServiceBrowser]()
    var netservices = [[NetService]]()
    var servicesForMenuItems = [NSMenuItem: NetService]()
    
    var netServiceToOpen: NetService?
    
    @IBOutlet weak var window: NSWindow!

    func applicationWillFinishLaunching(_ notification: Notification) {
        statusItem.menu = statusMenu
        statusItem.image = statusIcon
        
        for serviceType in serviceTypes {
            let browser = NetServiceBrowser()
            browser.delegate = self
            browser.searchForServices(ofType: serviceType, inDomain: "local.")
            serviceBrowsers.append(browser)
            netservices.append([])
        }
        
        updateMenu()
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        guard let i = serviceBrowsers.index(of: browser) else { return }
        netservices[i].append(service)
        service.delegate = self
        if !moreComing { updateMenu() }
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        guard let i = serviceBrowsers.index(of: browser) else { return }
        if let index = netservices[i].index(of: service) {
            netservices[i].remove(at: index)
        }
        if !moreComing { updateMenu() }
    }
    
    func updateMenu() {
        statusMenu.removeAllItems()
        servicesForMenuItems.removeAll()
        
        for i in serviceTypes.indices {
            let titleItem = NSMenuItem(title: serviceTypeNames[i], action: nil, keyEquivalent: "")
            titleItem.isEnabled = false
            statusMenu.addItem(titleItem)
            if netservices[i].isEmpty {
                let loadingItem = NSMenuItem(title: "No Services Found", action: nil, keyEquivalent: "")
                loadingItem.isEnabled = false
                statusMenu.addItem(loadingItem)
            } else {
                for service in netservices[i] {
                    let item = NSMenuItem(title: service.name, action: #selector(AppDelegate.connectToService(_:)), keyEquivalent: "")
                    servicesForMenuItems[item] = service
                    statusMenu.addItem(item)
                }
            }
            statusMenu.addItem(NSMenuItem.separator())
        }
        let quitItem = NSMenuItem(title: "Quit Bonjour Menu", action: #selector(NSApplication.terminate), keyEquivalent: "")
        statusMenu.addItem(quitItem)
    }
    
    @objc func connectToService(_ sender: NSMenuItem) {
        guard let service = servicesForMenuItems[sender] else { NSSound.beep(); return }
        netServiceToOpen = service
        service.delegate = self
        service.resolve(withTimeout: 3)
    }
    
    func netServiceDidResolveAddress(_ sender: NetService) {
        guard netServiceToOpen == sender else { return }
        let scheme = sender.type.dropLast(6).dropFirst()
        let qs = scheme == "postgresql" ? "?nickname=\(sender.name.addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed)!)" : "";
        guard let hostname = sender.hostName?.trimmingCharacters(in: CharacterSet(charactersIn: ".")) else { NSSound.beep(); return }
        guard let url = URL(string:"\(scheme)://\(hostname):\(sender.port)\(qs)") else { NSSound.beep(); return }
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

