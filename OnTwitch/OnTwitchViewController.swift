//
//  OnTwitchViewController.swift
//  OnTwitch
//
//  Created by Steve on 2020-04-01.
//  Copyright © 2020 Steve. All rights reserved.
//

import Cocoa

class OnTwitchViewController: NSViewController, NSTextFieldDelegate {
    
    @IBOutlet weak var textField: NSTextField!
    @IBOutlet weak var outputLabel: NSTextField!
    @IBOutlet weak var errorLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do view setup here.
        textField.delegate = self
        
        writeNowInTextField()
    } 
    
    @objc func textFieldDidChange(_ textField: NSTextField) {

    }
    
    public func controlTextDidEndEditing(_ obj: Notification) {
        renderOutput()
    }
    
    public func controlTextDidChange(_ obj: Notification) {
        renderOutput()
    } 
    
    func renderOutput() {
    }
    
    /**
     * Determine whether to interpret the input as milliseconds or seconds
     * and returns the scaled OnTwitch and the unit descriptor.
     */
    func tsScaleFormat(ts: Double) -> (Double, String) {
    }
    
    func writeTsInTextField(ts: Double) {
        textField.stringValue = String(format: "%.0f", (ts).rounded())
        renderOutput()
    }
    
    func writeNowInTextField() {
        writeTsInTextField(ts: NSDate().timeIntervalSince1970)
    }
}

extension OnTwitchViewController {
    @IBAction func now(_ sender: NSButton) {
        writeNowInTextField()
    }
}

extension OnTwitchViewController {
    // MARK: Storyboard instantiation
    static func freshController() -> OnTwitchViewController {

        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)

        let identifier = NSStoryboard.SceneIdentifier("OnTwitchViewController")

        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? OnTwitchViewController else {
            fatalError("Cannot find OnTwitchViewController, check Main.storyboard")
        }

        return viewcontroller
    }
}
