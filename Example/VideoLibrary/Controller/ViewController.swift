//
//  ViewController.swift
//  video app
//
//  Created by Alexander Bozhko on 10/08/2018.
//  Copyright © 2018 Filmgrail AS. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Life cycle
    
    override func loadView() {
        view = SharedView(for: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - UI actions
    
    @objc func buttonPressed(_ sneder: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

}

