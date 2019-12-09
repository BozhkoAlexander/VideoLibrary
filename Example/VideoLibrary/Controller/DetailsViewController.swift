//
//  DetailsViewController.swift
//  video app
//
//  Created by Alexander Bozhko on 23/08/2018.
//  Copyright © 2018 Filmgrail AS. All rights reserved.
//

import UIKit
import VideoLibrary

class DetailsViewController: ViewController, VideoViewController {

    // MARK: - Transitioning
    
    var transition: DetailsTransition? = nil
    
    // MARK: - Properties
    
    var videoController = VideoController()
    
    func shouldPlayVideo(_ element: VideoElement) -> Bool {
        return true
    }
    
    let item: HomeItem
    
    var detailsView: DetailsView! { return view as? DetailsView }
    
    // MARK: - Life cycle
    
    init(_ item: HomeItem, sender: UIView?) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
        
        self.transition = DetailsTransition(sender: sender)
        self.transitioningDelegate = transition
        
        self.modalPresentationStyle = .custom
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func loadView() {
        view = DetailsView(for: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        detailsView.closeButton.addTarget(self, action: #selector(self.closePressed(_:)), for: .touchUpInside)
        enabledInteractiveDismissal()
        
        videoController.setup(detailsView, for: self)
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
    
    @objc func framePressed(_ sender: UIButton) {
        let state = detailsView.state == 0 ? 1 : 0
        let videoView = detailsView.videoView!
        videoView.backgroundColor = .orange
        let newFrame: CGRect
        if state == 0 {
            newFrame = CGRect(x: 0, y: 0, width: detailsView.bounds.width, height: round(9/16 * detailsView.bounds.width))
        } else {
            newFrame = CGRect(x: 20, y: 20, width: detailsView.bounds.width - 40, height: round(9/16 * (detailsView.bounds.width - 40)))
        }
        
        UIView.animate(withDuration: 0.35, animations: {
            videoView.frame = newFrame
        }) { [weak self] (_) in
            self?.detailsView.state = state
            self?.detailsView.setNeedsLayout()
        }
    }

}
