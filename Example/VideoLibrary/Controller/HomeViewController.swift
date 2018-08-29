//
//  HomeViewController.swift
//  video app
//
//  Created by Alexander Bozhko on 10/08/2018.
//  Copyright © 2018 Filmgrail AS. All rights reserved.
//

import UIKit
import VideoLibrary

class HomeViewController: ViewController, VideoViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Properties
    
    var videoController = VideoController()
    
    var homeView: HomeView! { return view as! HomeView }
    
    var items = Array<HomeItem>()
    
    // MARK: - Life cycle
    
    override func loadView() {
        view = HomeView(for: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Home"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Switch", style: .plain, target: self, action: #selector(self.switchPage))
        
        videoController.setupCollectionView(homeView.collectionView)
        
        if #available(iOS 10.0, *) {
            homeView.collectionView?.refreshControl = UIRefreshControl()
            homeView.collectionView?.refreshControl?.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        }
        
        refresh()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        videoController.sync()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Content
    
    @objc func refresh() {
        HomeItem.fetchHome { [weak self] (items, error) in
            if #available(iOS 10.0, *) {
                self?.homeView.collectionView?.refreshControl?.endRefreshing()
            }
            self?.items = items
            self?.update()
        }
    }
    
    func update() {
        homeView.collectionView.reloadSections(IndexSet(integer: 0))
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.videoController.sync()
        }
    }
    
    // MARK: - UI actions
    
    @objc func switchPage() {
        AppDelegate.shared.restart()
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
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - 36
        let height = ceil(9/16 * width)
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: HomeItemCell.cellId, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? HomeItemCell else { return }
        cell.item = items[indexPath.item]
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        videoController.collectionView(collectionView, didEndDisplaying: cell, forItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        videoController.collectionView(collectionView, didSelectItemAt: indexPath)
        guard let cell = collectionView.cellForItem(at: indexPath) as? HomeItemCell, let item = cell.item else { return }
        Video.shared.forceVideo = item.video
        
        let vc = DetailsViewController(item, videoView: cell.videoView)
        self.present(vc, animated: true)
    }

}
