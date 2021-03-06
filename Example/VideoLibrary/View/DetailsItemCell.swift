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
        videoView.layer.cornerRadius = 0
        clipsToBounds = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let height = round(9/16 * contentView.bounds.width)
        videoView.frame = CGRect(x: 0, y: contentView.bounds.height - height, width: contentView.bounds.width, height: height)
    }
    
}
