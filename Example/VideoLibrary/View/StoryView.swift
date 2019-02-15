//
//  StoryView.swift
//  VideoLibrary_Example
//
//  Created by Alexander Bozhko on 15/02/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import VideoLibrary

class StoryView: UIView, VideoElement {
    
    weak var videoView: VideoView! = nil
    weak var closeButton: UIButton! = nil
    
    private func setupVideoView() {
        let view = VideoView()
        view.backgroundColor = .darkGray
        
        addSubview(view)
        videoView = view
    }
    
    private func setupCloseButton(_ target: Any?, action: Selector) {
        let button = UIButton(type: .custom)
        button.setTitle("Close", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(target, action: action, for: .touchUpInside)
        
        addSubview(button)
        closeButton = button
    }
    
    // MARK: Life cycle
    
    init(_ target: Any?, closeAction: Selector) {
        super.init(frame: .zero)
        
        setupVideoView()
        setupCloseButton(target, action: closeAction)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    // MARK: Video element
    
    func video(_ element: VideoElement, didChangeStatus status: Video.Status, withContainer container: Video.Container?) {
        print("didChangeStatus \(status)")
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        videoView.frame = bounds
        var safeBounds = bounds
        if #available(iOS 11.0, *) {
            safeBounds = bounds.inset(by: safeAreaInsets)
        }
        
        if let text = closeButton.title(for: .normal) as NSString? {
            closeButton.frame.size = text.boundingRect(with: .zero, options: .usesLineFragmentOrigin, attributes: [.font: closeButton.titleLabel!.font], context: nil).size
            closeButton.frame.size.width += 40
            closeButton.frame.size.height += 20
        } else {
            closeButton.frame.size = .zero
        }
        closeButton.frame.origin = safeBounds.origin
    }
    
}
