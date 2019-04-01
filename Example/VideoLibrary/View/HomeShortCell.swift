//
//  HomeShortCell.swift
//  VideoLibrary
//
//  Created by Alexander Bozhko on 04/09/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

class HomeShortCell: UICollectionViewCell, HomeItemElement {
    
    // MARK: - Binding
    
    var item: HomeItem? = nil {
        willSet {
            guard item != newValue else { return }
            imageObservation = nil
            titleObservation = nil
        }
        didSet {
            guard item != oldValue else { return }
            imageObservation = item?.observe(\.image, options: .initial, changeHandler: { [weak self] (item, _) in
                self?.imageView.setImage(item.image)
            })
            titleObservation = item?.observe(\.title, options: .initial, changeHandler: { [weak self] (item, _) in
                self?.titleLabel.text = item.title
            })
        }
    }
    
    var imageObservation: NSKeyValueObservation? = nil
    var titleObservation: NSKeyValueObservation? = nil
    
    // MARK: - Subviews & Video Element
    
    weak var imageView: UIImageView! = nil
    weak var titleLabel: UILabel! = nil
    
    private func setupImageView() {
        let view = UIImageView()
        view.backgroundColor = .lightGray
        view.contentMode = .scaleAspectFill
        
        view.clipsToBounds = true
        view.layer.cornerRadius = 5
        
        contentView.addSubview(view)
        imageView = view
    }
    
    private func setupTitleLabel() {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = .black
        
        contentView.addSubview(label)
        titleLabel = label
    }
    
    // MARK: - Life cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        layer.cornerRadius = 10
        clipsToBounds = true
        
        setupImageView()
        setupTitleLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    deinit {
        imageObservation = nil
        titleObservation = nil
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame.size.height = contentView.bounds.height - 20
        imageView.frame.size.width = imageView.frame.height
        imageView.frame.origin = CGPoint(x: 10, y: 10)
        
        titleLabel.frame = CGRect(x: imageView.frame.maxX + 10, y: 10, width: contentView.bounds.width - 20 - imageView.frame.maxX, height: contentView.bounds.height - 20)
    }
    
}
