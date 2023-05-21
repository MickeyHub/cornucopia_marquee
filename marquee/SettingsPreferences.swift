//
//  Preferences.swift
//  marquee
//
//  Created by shayanbo on 2023/5/21.
//

import UIKit

class SettingsPreferences {
    
    let userDefault: UserDefaults?
    
    init() {
        self.userDefault = UserDefaults(suiteName: "marquee")
    }
    
    var text: String? {
        get {
            userDefault?.string(forKey: "text")
        }
        set {
            userDefault?.set(newValue, forKey: "text")
            userDefault?.synchronize()
        }
    }
    
    var textColor: UIColor {
        get {
            var textColor = UIColor.black
            if let textColorData = userDefault?.data(forKey: "text_color") {
                if let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: textColorData) {
                    textColor = color
                }
            }
            return textColor
        }
        set {
            if let data = try? NSKeyedArchiver.archivedData(withRootObject: newValue, requiringSecureCoding: true) {
                userDefault?.set(data, forKey: "text_color")
                userDefault?.synchronize()
            }
        }
    }
    
    var backgroundColor: UIColor {
        get {
            var bgColor = UIColor.white
            if let textColorData = userDefault?.data(forKey: "background_color") {
                if let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: textColorData) {
                    bgColor = color
                }
            }
            return bgColor
        }
        set {
            if let data = try? NSKeyedArchiver.archivedData(withRootObject: newValue, requiringSecureCoding: true) {
                userDefault?.set(data, forKey: "background_color")
                userDefault?.synchronize()
            }
        }
    }
    
    var speed: SettingsController.Speed {
        get {
            if let storedSpeed = userDefault?.integer(forKey: "speed") {
                return SettingsController.Speed(rawValue: storedSpeed)!
            } else {
                return SettingsController.Speed.normal
            }
        }
        set {
            userDefault?.set(newValue.rawValue, forKey: "speed")
            userDefault?.synchronize()
        }
    }
    
    var fontSize: SettingsController.FontSize {
        get {
            if let storedSize = userDefault?.integer(forKey: "font_size") {
                return SettingsController.FontSize(rawValue: storedSize)!
            } else {
                return SettingsController.FontSize.normal
            }
        }
        set {
            userDefault?.set(newValue.rawValue, forKey: "font_size")
            userDefault?.synchronize()
        }
    }
}
