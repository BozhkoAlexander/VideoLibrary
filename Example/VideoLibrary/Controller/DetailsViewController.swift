//
//  DetailsViewController.swift
//  video app
//
//  Created by Alexander Bozhko on 23/08/2018.
//  Copyright © 2018 Filmgrail AS. All rights reserved.
//

import UIKit
import VideoLibrary

class DetailsViewController: ViewController, VideoViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // MARK: - Transitioning
    
    var transition: DetailsTransition? = nil
    
    // MARK: - Properties
    
    var videoController = VideoController()
    
    let item: HomeItem
    
    var detailsView: DetailsView! { return view as? DetailsView }
    var headerView: DetailsItemCell? { return detailsView.collectionView?.visibleCells.compactMap({ $0 as? DetailsItemCell }).first }
    
    // MARK: - Life cycle
    
    init(_ item: HomeItem, sender: VideoCell?) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
        
        self.transition = DetailsTransition(sender: sender)
        self.transitioningDelegate = transition
        
        self.modalPresentationStyle = .custom
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = DetailsView(for: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        videoController.setup(detailsView.collectionView, for: self)

        detailsView.closeButton.addTarget(self, action: #selector(self.closePressed(_:)), for: .touchUpInside)
        enabledInteractiveDismissal()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        videoController.sync()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UI actions
    
    @objc func closePressed(_ sender: UIButton) {
        var vc = presentingViewController
        if let nc = vc as? UINavigationController {
            vc = nc.viewControllers.last
        }
        if transition?.sender == nil {
            Video.shared.forceVideo = nil
        }
        self.dismiss(animated: true) {
            Video.shared.sync(for: vc)
        }
    }
    
    // MARK: - Collection view delegate & data source
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        videoController.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        videoController.scrollViewDidEndDecelerating(scrollView)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        var height: CGFloat = 0
        if #available(iOS 11.0, *) {
            height = view.safeAreaInsets.top
        }
        height += ceil(9/16 * width)
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: DetailsItemCell.cellId, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? DetailsItemCell else { return }
        cell.item = item
        Video.shared.play(cell)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        videoController.collectionView(collectionView, didEndDisplaying: cell, forItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        videoController.collectionView(collectionView, didSelectItemAt: indexPath)
        guard let cell = collectionView.cellForItem(at: indexPath) as? VideoCell else { return }
        cell.videoView.setupPauseTimer()
        
    }

}
