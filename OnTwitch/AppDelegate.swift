//
//  AppDelegate.swift
//  OnTwitch
//
//  Created by Steve on 2020-04-01.
//  Copyright © 2020 Steve. All rights reserved.
//

import Cocoa
import SwiftUI

extension Array {
    func split() -> (left: [Element], right: [Element]) {
        let ct = self.count
        let half = ct / 2
        print (ct, 2, ct / 2)
        let leftSplit = self[0 ..< half]
        let rightSplit = self[half ..< ct]
        return (left: Array(leftSplit), right: Array(rightSplit))
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!

    // Strong reference to retain the status bar item object
    var statusItem: NSStatusItem?
    
    let popover = NSPopover()
    var eventMonitor: EventMonitor?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: -1)
        
        guard let button = statusItem?.button else {
            print("status bar item failed. Try removing some menu bar item.")
            NSApp.terminate(nil)
            return
        }
        
        button.image = NSImage(named: "MenuBarButton")
        button.title = "loading..."
        
        button.target = self
        button.action = #selector(updateStatusBar(_:))
        
        _ = Timer.scheduledTimer(timeInterval: 120,
        target: self,
        selector: #selector(updateStatusBar(_:)),
        userInfo: nil,
        repeats: true)
        
        checkstreamer()
        
        popover.contentViewController = OnTwitchViewController.freshController()
        
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
          if let strongSelf = self, strongSelf.popover.isShown {
            strongSelf.closePopover(sender: event)
          }
        }
    }
    
    
    func checkstreamer(){
        let httpUrl = "https://api.twitch.tv/helix/streams/followed?user_id=20766903"

        guard let url = URL(string: httpUrl) else {
            return
        }

        var request = URLRequest(url: url)

        // Todo: add client id and key from secret config or envvars
        request.setValue("Bearer " + SecretKey, forHTTPHeaderField: "Authorization")
        request.setValue(ClientId, forHTTPHeaderField: "Client-Id")
        
        let task = NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main) {(response, data, error) in
            guard let data = data else { return }
            
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            
            
            
            if let root = json as? [String: Any] {
                if let data = root["data"] as? [[String: Any]] {
                    
                    
                    let usernames = data.map { ele in
                        return ele["user_name"] as! String
                    } as [String]
                    
                    self.constructMenuStreams(streams: data.map { ele in
                        return "\(ele["game_name"] as! String) \(ele["user_login"] as! String)"
                    })
                    
                    let st = usernames.joined(separator: " ")
                    
                    self.statusItem?.button?.title = st.isEmpty ? "no live streams" : st
                    
                    self.showNotification(ids: usernames) // image: NSImage(contentsOf: imageUrl)!

                }
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @objc func updateStatusBar(_ sender: Any?) {
        checkstreamer()
    }
    
    func showNotification(ids: [String]) -> Void {
        let notification = NSUserNotification()
        
        return
        
        if (ids.isEmpty) {
        print("no streams, no need to send notification")
            return
        }
        
        print (ids)
        let both = ids.split()
        print(both)
        
        let titleString = both.left.joined(separator: " ")
        notification.title = titleString.isEmpty ? "Live Streams" : titleString
        notification.subtitle = both.right.joined(separator: " ")
        
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    @objc func togglePopover(_ sender: Any?) {
      if popover.isShown {
        closePopover(sender: sender)
      } else {
        showPopover(sender: sender)
      }
    }

    func showPopover(sender: Any?) {
        if let button = statusItem?.button {
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
      }
        
      eventMonitor?.start()
    }

    func closePopover(sender: Any?) {
      popover.performClose(sender)
        
      eventMonitor?.stop()
    }
    
    func constructMenuStreams(streams: [String]) {
      let menu = NSMenu()
        
        for stream in streams {
            menu.addItem(NSMenuItem(title: stream, action: #selector(openUrl), keyEquivalent: (stream.first?.lowercased())!))
        }

      menu.addItem(NSMenuItem.separator())
      menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
      statusItem?.menu = menu
    }
    
    @objc func openUrl(sender: NSMenuItem) {
        guard let url = URL(string: "https://twitch.tv/" + sender.title) else { return }
        NSWorkspace.shared.open(url)
    }
    
    func constructMenu() {
      let menu = NSMenu()

      menu.addItem(NSMenuItem(title: "To Date", action: #selector(AppDelegate.togglePopover(_:)), keyEquivalent: "D"))
      menu.addItem(NSMenuItem.separator())
      menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

      statusItem?.menu = menu
    }
}

