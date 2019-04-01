//
//  DetailsView.swift
//  video app
//
//  Created by Alexander Bozhko on 23/08/2018.
//  Copyright © 2018 Filmgrail AS. All rights reserved.
//

import UIKit

class DetailsView: UIView {
    
    // MARK: - Subviews
    
    weak var collectionView: UICollectionView! = nil
    weak var closeButton: UIButton! = nil
    
    private func setupCollectionView(for delegate: UICollectionViewDelegate & UICollectionViewDataSource) {
        let layout = UICollectionViewFlowLayout()
        let view = UICollectionView(frame: bounds, collectionViewLayout: layout)
        view.backgroundColor = .brown
        
        if #available(iOS 11.0, *) {
            view.contentInsetAdjustmentBehavior = .never
        }
                
        view.register(DetailsItemCell.self, forCellWithReuseIdentifier: DetailsItemCell.cellId)
        
        view.alwaysBounceVertical = true
        
        view.delegate = delegate
        view.dataSource = delegate
        
        addSubview(view)
        collectionView = view
    }
    
    private func setupCloseButton() {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "CloseIcon"), for: .normal)
        
        addSubview(button)
        closeButton = button
    }
    
    // MARK: - Life cycle
    
    init(for vc: DetailsViewController) {
        super.init(frame: .zero)
        
        setupCollectionView(for: vc)
        setupCloseButton()
        
        backgroundColor = .purple
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        collectionView.frame = bounds
        
        var minY: CGFloat = 0
        if #available(iOS 11.0, *) {
            minY = safeAreaInsets.top
        }
        
        closeButton.frame.size = closeButton.image(for: .normal)!.size
        closeButton.frame.size.width += 36
        closeButton.frame.size.height += 36
        closeButton.frame.origin = CGPoint(x: bounds.width - closeButton.frame.width, y: minY)
    }
    
}
