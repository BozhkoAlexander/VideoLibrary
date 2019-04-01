//
//  HomeView.swift
//  video app
//
//  Created by Alexander Bozhko on 10/08/2018.
//  Copyright © 2018 Filmgrail AS. All rights reserved.
//

import UIKit

class HomeView: UIView {
    
    // MARK: - Subviews
    
    weak var collectionView: UICollectionView!
    
    private func setupCollectionView(for delegate: UICollectionViewDelegate & UICollectionViewDataSource) {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 18
        layout.minimumLineSpacing = 18
        let view = UICollectionView(frame: bounds, collectionViewLayout: layout)
        view.backgroundColor = .groupTableViewBackground
        view.contentInset = UIEdgeInsets(top: 18, left: 0, bottom: 18, right: 0)
        
        view.register(HomeItemCell.self, forCellWithReuseIdentifier: HomeItemCell.cellId)
        view.register(HomeShortCell.self, forCellWithReuseIdentifier: HomeShortCell.cellId)
        
        view.delegate = delegate
        view.dataSource = delegate
        
        addSubview(view)
        collectionView = view
    }
    
    // MARK: - Life cycle
    
    init(for vc: HomeViewController) {
        super.init(frame: .zero)
        
        setupCollectionView(for: vc)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        collectionView.frame = bounds
    }

}
