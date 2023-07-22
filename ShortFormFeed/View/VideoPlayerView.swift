//
//  VideoPlayerView.swift
//  ShortFormFeed
//
//  Created by Allie on 2023/07/15.
//

import UIKit
import AVKit

import RxSwift
import RxCocoa

final class VideoPlayerView: UIView {
    // MARK: - Properties
    var playerLayer: AVPlayerLayer?
    var playerLooper: AVPlayerLooper?
    var queuePlayer: AVQueuePlayer?
    private let disposeBag = DisposeBag()

    private let mainView = UIView()
    private let soundButton: UIButton = {
        let button = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 30)
        let image = UIImage(systemName: "speaker.wave.2.fill", withConfiguration: imageConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        button.layer.masksToBounds = false
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.1
        
        return button
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        mainView.backgroundColor = .clear
        soundButton.rx.tap
            .asDriver()
            .drive(with: self, onNext: { owner, _ in
            owner.manageSound()
        })
        .disposed(by: disposeBag)
    }

    @available(*, unavailable)
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
    
    func setVideo(with urlString: String) {
        guard let videoURL = URL(string: urlString) else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let playItem = AVPlayerItem(url: videoURL)
            
            self.queuePlayer = AVQueuePlayer(playerItem: playItem)
            self.playerLayer = AVPlayerLayer()
            
            self.playerLayer?.frame = self.mainView.bounds
            self.playerLayer?.player = self.queuePlayer
            self.playerLayer?.videoGravity = .resizeAspectFill
            
            self.mainView.layer.addSublayer(self.playerLayer!)
            
            self.playerLooper = AVPlayerLooper(player: self.queuePlayer!, templateItem: playItem)
        }
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
        addSubview(mainView)
        addSubview(soundButton)
        
        mainView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        soundButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(50)
            make.trailing.equalToSuperview().offset(-20)
            make.width.height.equalTo(35)
        }
    }
}
