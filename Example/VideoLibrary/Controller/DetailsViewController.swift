//
//  DetailsViewController.swift
//  video app
//
//  Created by Alexander Bozhko on 23/08/2018.
//  Copyright © 2018 Filmgrail AS. All rights reserved.
//

import UIKit
import VideoLibrary

class DetailsViewController: ViewController, VideoViewController, DetailsAnimatorDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // MARK: - Transitioning
    
    var transition: DetailsTransition? = nil
    
    // MARK: - Properties
    
    var videoController = VideoController()
    
    let item: HomeItem
    
    var detailsView: DetailsView! { return view as? DetailsView }
    var headerView: DetailsItemCell? { return detailsView.collectionView?.visibleCells.compactMap({ $0 as? DetailsItemCell }).first }
    
    // MARK: - Life cycle
    
    init(_ item: HomeItem, videoView: VideoView? = nil) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
        
        guard let videoView = videoView else { return }
        self.transition = DetailsTransition(videoView)
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self.transition
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = DetailsView(for: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        videoController.setupScrollView(detailsView.collectionView)

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
        self.dismiss(animated: true) {
            Video.shared.sync(for: vc)
        }
    }
    
    // MARK: - Details animator delegate
    
    func prepare(using transitionContext: UIViewControllerContextTransitioning, isPresentation: Bool) {
        detailsView.closeButton.alpha = 0
        detailsView.collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func animate(using transitionContext: UIViewControllerContextTransitioning, isPresentation: Bool) {}
    
    func finish(using transitionContext: UIViewControllerContextTransitioning, isPresentation: Bool) {
        guard isPresentation || transitionContext.transitionWasCancelled else {
            if let videoView = (transitioningDelegate as? DetailsTransition)?.senderView {
                videoView.stopPauseTimer()
            }
            return
        }
        if let videoView = (transitioningDelegate as? DetailsTransition)?.senderView {
            headerView?.replace(videoView: videoView)
            headerView?.setNeedsLayout()
        }
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            self?.detailsView.closeButton.alpha = 1
        })
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
        guard let cell = collectionView.cellForItem(at: indexPath) as? CollectionVideoCell else { return }
        cell.videoView.setupPauseTimer()
        
    }

}
