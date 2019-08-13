//
//  TestView.swift
//  VideoLibrary_Example
//
//  Created by Alexander Bozhko on 27/06/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import VideoLibrary

class TestView: UIView {
    
    // MARK: - Properties
    
    weak var statusLabel: UILabel! = nil
    
    weak var videoView: BetaVideoView! = nil
    
    private func setupStatusLabel() {
        let label = UILabel()
        
        addSubview(label)
        statusLabel = label
    }
    
    private func setupVideoView(for vc: TestViewController) {
        let view = BetaVideoView()
        
        view.delegate = vc
        
        addSubview(view)
        videoView = view
    }
    
    // MARK: - Life cycle
    
    init(for vc: TestViewController) {
        super.init(frame: .zero)
        
        backgroundColor = .groupTableViewBackground
        
        setupStatusLabel()
        setupVideoView(for: vc)
        
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    // MARK: - Layout
    
    private func setupLayout() {
        videoView.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            videoView.leadingAnchor.constraint(equalTo: leadingAnchor),
            videoView.trailingAnchor.constraint(equalTo: trailingAnchor),
            videoView.heightAnchor.constraint(equalTo: videoView.widthAnchor, multiplier: 9/16),
            videoView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            statusLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            statusLabel.bottomAnchor.constraint(equalTo: videoView.topAnchor, constant: -20)
        ])
    }
    
}
