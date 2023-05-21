//
//  EntryController.swift
//  marquee
//
//  Created by shayanbo on 2023/5/20.
//

import UIKit

public class EntryController: UIViewController, UIGestureRecognizerDelegate {
    
    /// Persistence
    let preferences = SettingsPreferences()
    
    /// View
    var label: UILabel!
    
    /// Timer
    var timer: Timer?
    
    public override func viewDidLoad() {
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        view.backgroundColor = preferences.backgroundColor
        
        label = UILabel()
        label.text = preferences.text
        label.textColor = preferences.textColor
        label.font = font(from: preferences.fontSize)
        label.transform = CGAffineTransformMakeRotation(CGFloat.pi * 0.5)
        
        view.addSubview(label)
        label.frame = view.bounds.offsetBy(dx: 0, dy: view.frame.height)
        self.updateLabelWidth()
    }
    
    func updateLabelWidth() {
        let width = (self.preferences.text as NSString).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [
            .font: self.font(from: self.preferences.fontSize)
        ], context: nil).width
        var frame = self.label.frame
        frame.size.height = width
        self.label.frame = frame
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        let timer = Timer(timeInterval: 1, repeats: true, block: { [weak self] timer in
            guard let self = self else { return }
            
            UIView.animate(withDuration: 1, delay: 0, options: .curveLinear) {
                var frame = self.label.frame
                frame.origin.y -= self.speed(from: self.preferences.speed)
                self.label.frame = frame
            } completion: { _ in
                print(self.label.frame.maxY)
                let overflow = self.label.frame.maxY < 0
                if overflow {
                    var frame = self.label.frame
                    frame.origin.y = self.view.frame.height
                    self.label.frame = frame
                }
            }
        })
        
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        timer?.invalidate()
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let observer = SettingsController.Observer { [weak self] text in
            
            guard let self = self else { return }
            self.label.text = text
            
            /// update label size
            self.updateLabelWidth()
        } speed: { _ in
            
        } font: { [weak self] fontSize in
            
            guard let self = self else { return }
            self.label.font = self.font(from: fontSize)
            
            /// update label size
            self.updateLabelWidth()
        } textColor: { [weak self] textColor in
            
            guard let self = self else { return }
            self.label.textColor = textColor
        } backgroundColor: { [weak self] backgroundColor in
            
            guard let self = self else { return }
            self.view.backgroundColor = backgroundColor
        }
        
        let settings = SettingsController(observer: observer)
        if #available(iOS 15, *) {
            settings.sheetPresentationController?.detents = [.medium()]
        }
        
        self.present(settings, animated: true)
    }
}

extension EntryController {
    
    func font(from: SettingsController.FontSize) -> UIFont {
        switch self.preferences.fontSize {
        case .small:
            return .systemFont(ofSize: 70)
        case .normal:
            return .systemFont(ofSize: 100)
        case .large:
            return .systemFont(ofSize: 150)
        case .huge:
            return .systemFont(ofSize: 200)
        }
    }
    
    func speed(from: SettingsController.Speed) -> Double {
        switch self.preferences.speed {
        case .low:
            return 50
        case .normal:
            return 100
        case .fast:
            return 200
        case .speed:
            return 300
        }
    }
}
