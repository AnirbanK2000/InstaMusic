//
//  PopoverViewController.swift
//  InstaMusic
//
//  Created by Anirban Kumar on 2/19/20.
//  Copyright © 2020 Anirban Kumar. All rights reserved.
//

import UIKit

class PopoverViewController: UIViewController {

    @IBOutlet weak var shadowSwitch: UISwitch!
    @IBOutlet weak var darkBlurSwitch: UISwitch!
    var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Settings"
        //self.navigationController?.isNavigationBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
      
    }
}
