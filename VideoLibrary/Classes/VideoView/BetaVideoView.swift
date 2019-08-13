//
//  VideoView.swift
//  VideoLibrary
//
//  Created by Alexander Bozhko on 27/06/2019.
//

import UIKit
import AVKit

open class BetaVideoView: UIImageView {
    
    // MARK: - Public properties
    
    /// Video link for the video view. Observable.
    @objc dynamic public var link: String? = nil {
        didSet {
            guard link != oldValue else { return }
            reset()
        }
    }
    
    /// State of the video view.
    public private(set) var state: State = .empty {
        didSet {
            guard state != oldValue else { return }
            didChangedState()
            delegate?.videoView(self, didChangedState: state)
        }
    }
    
    /// The flag shows if the video video does buffering of the video. Observable.
    @objc dynamic public private(set) var isBuffering: Bool = false
    
    /// Delegate of the video view (weak reference).
    public weak var delegate: VideoViewDelegate? = nil
    
    // MARK: - Public subviews & sublayers
    
    /// The main video layer that plays video.
    public weak var videoLayer: AVPlayerLayer! = nil
    
    private func setupVideoLayer() {
        let videoLayer = AVPlayerLayer(player: nil)
        videoLayer.backgroundColor = UIColor.black.cgColor
        videoLayer.opacity = 0
        
        layer.addSublayer(videoLayer)
        self.videoLayer = videoLayer
        
        setupKVO()
    }
    
    // MARK: - KVO
    
    private var playerKVO: NSKeyValueObservation! = nil
    
    private var timeControlStatusKVO: NSKeyValueObservation! = nil
    
    private func setupKVO() {
        playerKVO = videoLayer.observe(\.player, options: .new) { [weak self] (videoLayer, _) in
            self?.didChangedState()
            
            if #available(iOS 10.0, *) {
                self?.timeControlStatusKVO = videoLayer.player?.observe(\.timeControlStatus, options: .initial, changeHandler: { (player, _) in
                    switch player.timeControlStatus {
                    case .paused: print("DEBUG paused")
                    case .playing: print("DEBUG playing")
                    case .waitingToPlayAtSpecifiedRate: print("DEBUG waitingToPlayAtSpecifiedRate")
                    @unknown default: break
                    }
                })
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    private func setupNotificationsObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayToEndTime(_:)), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    private func tearDownNotificationsObserver() {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    @objc func playerItemDidPlayToEndTime(_ notification: Notification) {
        guard let item = notification.object as? AVPlayerItem, item == videoLayer.player?.currentItem else { return }
        stop()
    }
    
    // MARK: - Life cycle
    
    public init() {
        super.init(frame: .zero)
        
        setupVideoLayer()
        
        setupNotificationsObserver()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    deinit {
        tearDownNotificationsObserver()
    }
    
    // MARK: - Layout
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        videoLayer.frame = bounds
    }
    
    open override var intrinsicContentSize: CGSize {
        return videoLayer.videoRect.size
    }
    
    // MARK: - Public methods
    
    /// Load video without playback starting.
    /// - Parameters:
    ///     - callback: Callback which called when the video loaded.
    open func load(_ callback: (() -> Void)?) {
        guard videoLayer.player == nil else { return }
        Video.shared.load(link) { [weak self] (container, isCached, error) in
            guard let this = self else { return }
            this.videoLayer.player = container?.player
            this.didChangedState()
            callback?()
        }
    }
    
    /// Start playback of the video. Load video if needed.
    open func play() {
        if let player = videoLayer.player {
            player.play()
        } else {
            load { [weak self] in
                self?.videoLayer.player?.play()
            }
        }
        
        state = .playing
    }
    
    /// Pause video.
    open func pause() {
        videoLayer.player?.pause()
        
        state = .paused
    }
    
    /// Stop video.
    open func stop() {
        videoLayer.player?.pause()
        videoLayer.player?.seek(to: .zero)
        
        state = .stopped
    }
    
    // MARK: - Private methods
    
    private func reset() {
        videoLayer.player = nil
        videoLayer.opacity = 0
    }
    
    private func didChangedState() {
        let hasPlayer = videoLayer.player != nil
        videoLayer.opacity = hasPlayer ? state.videoLayerOpacity : 0
    }

}
