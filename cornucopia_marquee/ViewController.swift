//
//  ViewController.swift
//  cornucopia_marquee
//
//  Created by shayanbo on 2023/5/21.
//

import UIKit
import marquee

class ViewController : UIViewController {
    
    override func viewDidLoad() {
        self.view.backgroundColor = .white
        self.navigationItem.title = "Single"
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        navigationController?.pushViewController(EntryController(), animated: true)
    }
}
