//
//  DetailsView.swift
//  video app
//
//  Created by Alexander Bozhko on 23/08/2018.
//  Copyright © 2018 Filmgrail AS. All rights reserved.
//

import UIKit
import VideoLibrary

class DetailsView: UIView, VideoElement {
    
    // MARK: - Subviews
    
    weak var videoView: VideoView! = nil
    
    weak var closeButton: UIButton! = nil
    
    weak var frameButton: UIButton! = nil
    
    private func setupVideoView(for vc: DetailsViewController) {
        let view = VideoView()
        view.setVideo(vc.item.video, autoplay: true)
        
        addSubview(view)
        videoView = view
    }
    
    private func setupCloseButton() {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "CloseIcon"), for: .normal)
        
        addSubview(button)
        closeButton = button
    }
    
    private func setupFrameButton(for vc: DetailsViewController) {
        let button = UIButton(type: .custom)
        button.setTitle("Change frame", for: .normal)
        
        button.addTarget(vc, action: #selector(vc.framePressed(_:)), for: .touchUpInside)
        
        addSubview(button)
        frameButton = button
    }
    
    // MARK: - Video view
    
    func video(_ element: VideoElement, didChangeStatus status: Video.Status, withContainer container: Video.Container?) {
        
    }
    
    // MARK: - Life cycle
    
    init(for vc: DetailsViewController) {
        super.init(frame: .zero)
        
        setupVideoView(for: vc)
        setupCloseButton()
        setupFrameButton(for: vc)
        
        backgroundColor = .purple
        
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    // MARK: - Layout
    
    var state = 0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var minY: CGFloat = 0
        if #available(iOS 11.0, *) {
            minY = safeAreaInsets.top
        }
        
        closeButton.frame.size = closeButton.image(for: .normal)!.size
        closeButton.frame.size.width += 36
        closeButton.frame.size.height += 36
        closeButton.frame.origin = CGPoint(x: bounds.width - closeButton.frame.width, y: minY)
        
        if state == 0 {
            videoView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: round(9/16 * bounds.width))
        } else {
            videoView.frame = CGRect(x: 20, y: 20, width: bounds.width - 40, height: round(9/16 * (bounds.width - 40)))
        }
    }
    
    private func setupLayout() {
        frameButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            frameButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            frameButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            frameButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
}
