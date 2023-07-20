//
//  VideoPlayerView.swift
//  ShortFormFeed
//
//  Created by Allie on 2023/07/15.
//

import UIKit
import AVKit

final class VideoPlayerView: UIView {
    // MARK: - Properties
    var playerLayer: AVPlayerLayer?
    var playerLooper: AVPlayerLooper?
    var queuePlayer: AVQueuePlayer?
    var urlString: String

    private let soundButton: UIButton = {
        let button = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 30)
        let image = UIImage(systemName: "speaker.wave.2.fill", withConfiguration: imageConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        
        return button
    }()
    
    // MARK: - Initializer
    init(frame: CGRect, urlString: String) {
        self.urlString = urlString
        super.init(frame: frame)

        let videoURL = URL(string: urlString)!
        let playItem = AVPlayerItem(url: videoURL)

        self.queuePlayer = AVQueuePlayer(playerItem: playItem)
        playerLayer = AVPlayerLayer()

        playerLayer?.player = queuePlayer
        playerLayer?.videoGravity = .resizeAspectFill

        self.layer.addSublayer(playerLayer!)

        playerLooper = AVPlayerLooper(player: queuePlayer!, templateItem: playItem)
        setupLayout()
        queuePlayer?.play()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }
    
    // MARK: - Methods
    func cleanup() {
        queuePlayer?.pause()
        queuePlayer?.removeAllItems()
        queuePlayer = nil
    }
    
    func manageSound() {
        if queuePlayer?.volume != 0 {
            queuePlayer?.volume = 0
            let imageConfig = UIImage.SymbolConfiguration(pointSize: 30)
            let image = UIImage(systemName: "speaker.slash.fill", withConfiguration: imageConfig)
            soundButton.setImage(image, for: .normal)
        } else {
            queuePlayer?.volume = 1
            let imageConfig = UIImage.SymbolConfiguration(pointSize: 30)
            let image = UIImage(systemName: "speaker.wave.2.fill", withConfiguration: imageConfig)
            soundButton.setImage(image, for: .normal)
        }
    }
    
    private func setupLayout() {
        addSubview(soundButton)
        
        soundButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(50)
            make.trailing.equalToSuperview().offset(-20)
            make.width.height.equalTo(35)
        }
    }
}
