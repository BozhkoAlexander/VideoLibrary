//
//  SharedView.swift
//  VideoLibrary_Example
//
//  Created by Alexander Bozhko on 26/09/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

class SharedView: UIView {
    
    // MARK: - Subviews

    weak var button: UIButton! = nil
    
    private func setupButton(for vc: ViewController) {
        let button = UIButton(type: .custom)
        button.setTitle("Close", for: .normal)
        button.addTarget(vc, action: #selector(vc.buttonPressed(_:)), for: .touchUpInside)
        
        addSubview(button)
        self.button = button
    }
    
    // MARK: - Life cycle
    
    init(for vc: ViewController) {
        super.init(frame: .zero)
        
        backgroundColor = .groupTableViewBackground
        
        setupButton(for: vc)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let text = button.title(for: .normal) {
            let size = text.boundingRect(with: .zero, font: button.titleLabel!.font).size
            button.frame.size = CGSize(width: ceil(size.width) + 36, height: ceil(size.height) + 18)
            button.center = CGPoint(x: bounds.midX, y: bounds.midY)
        }
    }
    
}
