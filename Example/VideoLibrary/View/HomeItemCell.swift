//
//  HomeItemCell.swift
//  video app
//
//  Created by Alexander Bozhko on 10/08/2018.
//  Copyright © 2018 Filmgrail AS. All rights reserved.
//

import UIKit
import AVKit

import VideoLibrary

public protocol HomeItemElement {
    
    var item: HomeItem? { get set }
    
}

class HomeItemCell: UICollectionViewCell, HomeItemElement, VideoElement {

    // MARK: - Binding
    
    var item: HomeItem? = nil {
        willSet {
            guard item != newValue else { return }
            imageObservation = nil
            videoObservation = nil
        }
        didSet {
            guard item != oldValue else { return }
            imageObservation = item?.observe(\.image, options: .initial, changeHandler: { [weak self] (item, _) in
                self?.videoView?.setImage(item.image)
            })
            videoObservation = item?.observe(\.video, options: .initial, changeHandler: { [weak self] (item, _) in
                self?.videoView?.setVideo(item.video, autoplay: item.autoplay)
            })
        }
    }
    
    var imageObservation: NSKeyValueObservation? = nil
    var videoObservation: NSKeyValueObservation? = nil
    
    // MARK: - Subviews & Video Element
    
    weak var videoView: VideoView! = nil
    
    private func setupVideoView() {
        let view = VideoView()
        view.backgroundColor = .lightGray
        view.contentMode = .scaleAspectFill
        
        contentView.addSubview(view)
        videoView = view
    }
    
    func video(_ element: VideoElement, didChangeStatus status: Video.Status, withContainer container: Video.Container?) {
        switch status {
        case .empty:
            self.item?.video = nil
        case .ended,
             .paused:
            self.item?.autoplay = false
            self.videoView.autoplay = false
        default: break
        }
    }
    
    // MARK: - Life cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .green
        layer.cornerRadius = 10
        clipsToBounds = true
        
        setupVideoView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        imageObservation = nil
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        videoView.frame = contentView.bounds
    }
    
}
