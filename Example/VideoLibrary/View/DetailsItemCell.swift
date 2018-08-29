//
//  DetailsItemCell.swift
//  video app
//
//  Created by Alexander Bozhko on 24/08/2018.
//  Copyright © 2018 Filmgrail AS. All rights reserved.
//

import UIKit
import VideoLibrary

class DetailsItemCell: HomeItemCell {
    
    // MARK: - Life cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 0
        clipsToBounds = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /** Send video view from list to details */
    public func replace(videoView: VideoView) {
        self.videoView.removeFromSuperview()
        contentView.addSubview(videoView)
        self.videoView = videoView
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let height = round(9/16 * contentView.bounds.width)
        videoView.frame = CGRect(x: 0, y: contentView.bounds.height - height, width: contentView.bounds.width, height: height)
    }
    
}
