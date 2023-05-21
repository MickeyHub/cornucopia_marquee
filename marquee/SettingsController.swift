//
//  SettingsController.swift
//  marquee
//
//  Created by shayanbo on 2023/5/20.
//

import UIKit

class SettingsController: UIViewController {
    
    /// View
    var tableView: UITableView!
    var fontSizeView: UISegmentedControl!
    var speedView: UISegmentedControl!
    var textField: UITextField!
    var textColorBlock: UIView!
    var backgroundColorBlock: UIView!
    
    /// preferences
    var preferences = SettingsPreferences()
    
    /// Dirty flag
    var colorType = ColorType.none
    
    /// Callback
    let observer: Observer
    
    init(observer: Observer) {
        self.observer = observer
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        /// add tableview but empty at first
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        /// font size
        self.fontSizeView = UISegmentedControl(items: ["small", "normal", "large", "huge"])
        self.fontSizeView.selectedSegmentIndex = self.preferences.fontSize.rawValue
        self.fontSizeView.addTarget(self, action: #selector(fontSizeChanged), for: .valueChanged)
        
        /// speed
        self.speedView = UISegmentedControl(items: ["low", "normal", "fast", "speed"])
        self.speedView.selectedSegmentIndex = self.preferences.speed.rawValue
        self.speedView.addTarget(self, action: #selector(speedChanged), for: .valueChanged)
        
        /// text field
        self.textField = UITextField()
        self.textField.placeholder = "Type in here ..."
        self.textField.returnKeyType = .done
        self.textField.delegate = self
        self.textField.clearButtonMode = .whileEditing
        self.textField.text = self.preferences.text
        
        /// block
        self.textColorBlock = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 10))
        self.textColorBlock.backgroundColor = self.preferences.textColor
        
        self.backgroundColorBlock = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 10))
        self.backgroundColorBlock.backgroundColor = self.preferences.backgroundColor
    }
}

extension SettingsController {
    
    @objc func speedChanged() {
        
        var speed = Speed.normal
        switch self.speedView.selectedSegmentIndex {
        case 0:
            speed = .low
        case 1:
            speed = .normal
        case 2:
            speed = .fast
        case 3:
            speed = .speed
        default:
            break
        }
        /// store
        self.preferences.speed = speed
        /// callback
        self.observer.speed(speed)
    }
    
    @objc func fontSizeChanged() {
        
        var fontSize = FontSize.normal
        switch self.fontSizeView.selectedSegmentIndex {
        case 0:
            fontSize = .small
        case 1:
            fontSize = .normal
        case 2:
            fontSize = .large
        case 3:
            fontSize = .huge
        default:
            break
        }
        /// store
        self.preferences.fontSize = fontSize
        /// callback
        self.observer.font(fontSize)
    }
}

extension SettingsController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Text"
        case 1:
            return "Speed & Font Size"
        case 2:
            return "Foreground & Background Color"
        default:
            fatalError()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        switch indexPath.section {
        case 0:
            cell.imageView?.image = nil
            cell.accessoryView = self.textField
            cell.selectionStyle = .none
            
            self.textField.frame = cell.bounds
            self.textField.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        case 1:
            cell.selectionStyle = .none
            if indexPath.item == 0 {
                cell.imageView?.image = UIImage(systemName: "speedometer")
                cell.accessoryView = self.speedView
            } else {
                cell.imageView?.image = UIImage(systemName: "textformat.size")
                cell.accessoryView = self.fontSizeView
            }
        case 2:
            if indexPath.item == 0 {
                cell.imageView?.image = UIImage(systemName: "a.square")
                cell.accessoryView = self.textColorBlock
            } else {
                cell.imageView?.image = UIImage(systemName: "square")
                cell.accessoryView = self.backgroundColorBlock
            }
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.section == 2 else {
            return
        }
        
        self.colorType = indexPath.item == 0 ? .text : .background
        
        let colorPicker = UIColorPickerViewController()
        colorPicker.delegate = self
        self.present(colorPicker, animated: true)
    }
}

extension SettingsController: UIColorPickerViewControllerDelegate {
    
    enum ColorType {
        case none
        case text
        case background
    }
    
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        
        guard continuously == false else { return }
        
        switch self.colorType {
        case .background:
            /// store
            self.preferences.backgroundColor = viewController.selectedColor
            /// callback
            self.observer.backgroundColor(viewController.selectedColor)
            /// update UI
            self.backgroundColorBlock.backgroundColor = viewController.selectedColor
        case .text:
            /// store
            self.preferences.textColor = viewController.selectedColor
            /// callback
            self.observer.textColor(viewController.selectedColor)
            /// update UI
            self.textColorBlock.backgroundColor = viewController.selectedColor
        default:
            break
        }
    }
}

extension SettingsController {
    
    enum Speed: Int {
        case low = 0
        case normal
        case fast
        case speed
    }
    
    enum FontSize: Int {
        case small = 0
        case normal
        case large
        case huge
    }
}

extension SettingsController {
    
    struct Observer {
        let text: (String)->Void
        let speed: (Speed)->Void
        let font: (FontSize)->Void
        let textColor: (UIColor)->Void
        let backgroundColor: (UIColor)->Void
    }
}

extension SettingsController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        /// store
        self.preferences.text = textField.text ?? ""
        /// call back
        self.observer.text(textField.text ?? "")
        return true
    }
}

