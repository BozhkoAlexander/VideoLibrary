//
//  VideoView.swift
//  video app
//
//  Created by Alexander Bozhko on 13/08/2018.
//  Copyright © 2018 Filmgrail AS. All rights reserved.
//

import UIKit
import AVKit

public protocol VideoElement {
    
    var videoView: VideoView! { get set }
    
    func video(_ element: VideoElement, didChangeStatus status: Video.Status, withContainer container: Video.Container?)
    
}

public extension UIView {
    
    /** Send video view from list to details */
    func replace(videoView: VideoView) {
        guard var this = self as? VideoCell else { return }
        this.videoView.removeFromSuperview()
        var view: UIView = this
        if let contentView = (this as? UICollectionViewCell)?.contentView {
            view = contentView
        } else if let contentView = (this as? UITableViewCell)?.contentView {
            view = contentView
        }
        view.addSubview(videoView)
        this.videoView = videoView
    }
    
}

public class VideoView: UIImageView {
    
    // MARK: - Properties
    
    public var hidesWhenStopped = true // hide video layer when video is stopped
    public var disableAutoplayWhenEnded = true // disable autoplay for the second playing if the video has ended
        
    public var videoLink: String? = nil
    public var autoplay: Bool = false
    
    private var controlsTimer: Timer? = nil
    private var pauseTimer: Timer? = nil
    
    // MARK: - KVO
    
    private func startObservers() {
        videoLayer.player?.addObserver(self, forKeyPath: #keyPath(AVPlayer.isMuted), options: .new, context: nil)
    }
    
    private func stopObservers() {
        videoLayer.player?.removeObserver(self, forKeyPath: #keyPath(AVPlayer.isMuted))
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath != nil, let player = object as? AVPlayer else { return }
        self.volumeButton.isSelected = player.isMuted
    }
    
    // MARK: - Subviews
    
    public weak var videoLayer: AVPlayerLayer! = nil
    public weak var loader: UIActivityIndicatorView! = nil
    public weak var volumeButton: UIButton! = nil
    public weak var timeLabel: UILabel! = nil
    public weak var playButton: UIButton! = nil
    
    private func setupVideoLayer() {
        let layer = AVPlayerLayer(player: nil)
        layer.videoGravity = .resizeAspect
        layer.backgroundColor = UIColor.black.cgColor
        
        self.layer.addSublayer(layer)
        self.videoLayer = layer
    }
    
    private func setupLoader() {
        let loader = UIActivityIndicatorView(style: .white)
        loader.hidesWhenStopped = true
        self.addSubview(loader)
        self.loader = loader
    }
    
    private func setupVolumeButton() {
        let button = UIButton(type: .custom)
        let bundle = Bundle(for: self.classForCoder)
        let onImage = UIImage(named: "VolumeOnIcon", in: bundle, compatibleWith: nil)
        let offImage = UIImage(named: "VolumeOffIcon", in: bundle, compatibleWith: nil)
        button.setImage(onImage, for: .normal)
        button.setImage(offImage, for: .selected)
        button.layer.opacity = 0
        
        button.addTarget(self, action: #selector(self.volumePressed(_:)), for: .touchUpInside)
        
        self.addSubview(button)
        self.volumeButton = button
    }
    
    private func setupTimeLabel() {
        let label = UILabel()
        if #available(iOS 8.2, *) {
            label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        }
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        label.layer.cornerRadius = 6
        label.clipsToBounds = true
        
        self.addSubview(label)
        self.timeLabel = label
    }
    
    private func setupPlayButton() {
        let button = UIButton(type: .custom)
        let bundle = Bundle(for: self.classForCoder)
        let playImage = UIImage(named: "PlayIcon", in: bundle, compatibleWith: nil)
        let pauseImage = UIImage(named: "PauseIcon", in: bundle, compatibleWith: nil)
        button.setImage(playImage, for: .normal)
        button.setImage(pauseImage, for: .selected)
        button.layer.opacity = 0
        
        button.addTarget(self, action: #selector(self.playPressed(_:)), for: .touchUpInside)
        
        self.addSubview(button)
        self.playButton = button
    }
    
    private func setup() {
        isUserInteractionEnabled = true
        clipsToBounds = true
        
        setupVideoLayer()
        setupLoader()
        setupVolumeButton()
        setupTimeLabel()
        setupPlayButton()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTimeLabel(_:)), name: .VideoTimer, object: nil)
    }
    
    // MARK: - Life cycle
    
    override public init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
    }
    
    override public init(image: UIImage?) {
        super.init(image: image)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .VideoTimer, object: nil)
        stopControlsTimer()
        stopPauseTimer()
        stopObservers()
    }
    
    // MARK: - Timer settings
    
    public func stopPauseTimer() {
        pauseTimer?.invalidate()
        pauseTimer = nil
    }
    
    public func setupPauseTimer() {
        pauseTimer?.invalidate()
        pauseTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.hidePause), userInfo: nil, repeats: false)
        showPause()
    }
    
    private func stopControlsTimer() {
        controlsTimer?.invalidate()
        controlsTimer = nil
    }
    
    public func setupControlsTimer() {
        controlsTimer?.invalidate()
        controlsTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.hideControls), userInfo: nil, repeats: false)
        showControls()
    }
    
    @objc public func hideControls() {
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.volumeButton.layer.opacity = 0
            self?.timeLabel.layer.opacity = 0
        }
    }
    
    public func showControls() {
        volumeButton.layer.opacity = 1
        timeLabel.layer.opacity = 1
    }
    
    @objc public func hidePause() {
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.playButton.alpha = 0
        }
    }
    
    public func showPause() {
        playButton.isSelected = videoLayer.player != nil && videoLayer.player!.rate > 0
        playButton.alpha = 1
    }
    
    // MARK: - Public method
    
    public func setVideo(_ link: String?, autoplay: Bool = true) {
        stopControlsTimer()
        if link != videoLink {
            stopObservers()
            videoLayer.player = nil
        }
        self.videoLink = link
        self.autoplay = autoplay
        
        videoLayer.opacity = 0
        playButton.isSelected = false
        let hasVideo = link != nil && URL(string: link!) != nil
        playButton.layer.opacity = hasVideo ? 1 : 0
    }
    
    /** Link video container with view */
    public func setContainer(_ container: Video.Container?) {
        stopObservers()
        videoLayer.player = container?.player
        startObservers()
    }
    
    // MARK: - Update status
    
    public func update(status: Video.Status, container: Video.Container?) {
        var status = status
        if videoLink == nil || videoLink!.isEmpty {
            status = .empty
        }
        switch status {
        case .empty:
            setVideoOpacity(0)
            loader.stopAnimating()
            volumeButton.layer.opacity = 0
            timeLabel.layer.opacity = 0
            playButton.layer.opacity = 0
            // remove video because it's failed to load
            self.setVideo(nil, autoplay: false)
        case .loading:
            let isPlaying = container != nil
            setVideoOpacity(isPlaying ? 1 : 0)
            loader.startAnimating()
            volumeButton.layer.opacity = 0
            timeLabel.layer.opacity = 0
            playButton.layer.opacity = 0
        case .playing:
            setVideoOpacity(1)
            loader.stopAnimating()
            volumeButton.layer.opacity = 1
            volumeButton.isSelected = Video.shared.isMuted
            timeLabel.layer.opacity = 1
            playButton.layer.opacity = 0
            playButton.isSelected = true
            // start hide controls timer
            setupControlsTimer()
        case .stopped:
            if hidesWhenStopped {
                setVideoOpacity(0)
            } else {
                let videoOpacity: Float = videoLink != nil && !videoLink!.isEmpty ? 1 : 0
                setVideoOpacity(videoOpacity)
            }
            loader.stopAnimating()
            volumeButton.layer.opacity = 0
            timeLabel.layer.opacity = 0
            let hasVideo = videoLink != nil && URL(string: videoLink!) != nil
            playButton.layer.opacity = hasVideo ? 1 : 0
            playButton.isSelected = false
        case .paused:
            setVideoOpacity(1)
            loader.stopAnimating()
            playButton.layer.opacity = 1
            playButton.isSelected = false
            // start hide controls timer
            setupControlsTimer()
        case .ended:
            setVideoOpacity(0)
            loader.stopAnimating()
            volumeButton.layer.opacity = 0
            timeLabel.layer.opacity = 0
            playButton.isSelected = false
            playButton.layer.opacity = 1
            // disable autoplay
            if disableAutoplayWhenEnded {
                self.setVideo(videoLink, autoplay: false)
            }
        }
    }
    
    private func setVideoOpacity(_ opacity: Float) {
        guard videoLayer.opacity != opacity else { return }
        let path = #keyPath(CALayer.opacity)
        if let anim = videoLayer.animation(forKey: path) as? CABasicAnimation, anim.toValue as? Float == opacity {
            return
        }
        let anim = CABasicAnimation(keyPath: path)
        anim.duration = 0.5
        anim.fromValue = videoLayer.opacity
        videoLayer.opacity = opacity
        anim.toValue = opacity
        videoLayer.add(anim, forKey: path)
    }
    
    // MARK: - Update time label
    
    @objc func updateTimeLabel(_ notification: Notification) {
        guard let info = notification.object as? Video.TimerInfo, info.0.item == videoLayer.player?.currentItem else { return }
        timeLabel.text = info.1
        self.setNeedsLayout()
    }
    
    // MARK: - Layout
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let offset: CGFloat = 18
        
        videoLayer.frame = layer.bounds
        videoLayer.removeAllAnimations()

        loader.frame.origin.x = bounds.width - offset - loader.frame.width
        loader.frame.origin.y = bounds.height - offset - loader.frame.height
        
        var size = loader.bounds.size
        size.width += 2 * offset
        size.height += 2 * offset
        volumeButton.frame.size = size
        volumeButton.center = loader.center
        
        if let timeText = timeLabel.text, !timeText.isEmpty {
            timeLabel.frame.size.width = ceil(timeText.boundingRect(with: .zero, font: timeLabel.font).width) + offset
            timeLabel.frame.size.height = loader.frame.height
        } else {
            timeLabel.frame.size = .zero
        }
        timeLabel.center.y = loader.center.y
        timeLabel.frame.origin.x = offset
        
        playButton.frame.size = playButton.image(for: .normal)!.size
        playButton.frame.size.width += offset * 2
        playButton.frame.size.height += offset * 2
        playButton.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    // MARK: - UI actions
    
    @objc func volumePressed(_ sender: UIButton) {
        setupControlsTimer()
        Video.shared.isMuted = !sender.isSelected
    }
    
    @objc func playPressed(_ sender: UIButton) {
        if sender.isSelected {
            NotificationCenter.default.post(name: .VideoPausePressed, object: videoLink)
        } else {
            Video.shared.forceVideo = videoLink
            NotificationCenter.default.post(name: .VideoPlayPressed, object: self)
        }
    }
    
    // MARK: - Public methods (use only for the simple video view pages, not with scroll views)
    
    public func pause() {
        NotificationCenter.default.post(name: .VideoPausePressed, object: videoLink)
    }
    
    public func resume() {
        NotificationCenter.default.post(name: .VideoPlayPressed, object: self)
    }
    
}
