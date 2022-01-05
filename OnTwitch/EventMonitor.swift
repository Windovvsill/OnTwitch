//
//  EventMonitor.swift
//  OnTwitch
//
//  Created by Steve on 2020-04-01.
//  Copyright © 2020 Steve. All rights reserved.
//

import Foundation
import Cocoa

public class EventMonitor {
  private var monitor: Any?
  private let mask: NSEvent.EventTypeMask
  private let handler: (NSEvent?) -> Void

  public init(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent?) -> Void) {
    self.mask = mask
    self.handler = handler
  }

  deinit {
    stop()
  }

  public func start() {
    monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler)
  }

  public func stop() {
    if monitor != nil {
      NSEvent.removeMonitor(monitor!)
      monitor = nil
    }
  }
}
