//
//  AgentsViewController.swift
//  major-7-ios
//
//  Created by jason on 22/10/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit
import GlitchLabel

class AgentsViewController: UIViewController {

    @IBOutlet weak var label: GlitchLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray()

        label.lineBreakMode = .byCharWrapping
        label.text = "coming soon... coming soon... coming soon... coming soon..."
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }


}
