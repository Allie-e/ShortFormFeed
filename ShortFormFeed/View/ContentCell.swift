//
//  ContentCell.swift
//  ShortFormFeed
//
//  Created by Allie on 2023/07/22.
//

import UIKit

import SnapKit

final class ContentCell: UICollectionViewCell {
    // MARK: - UI
    private let videoView = VideoPlayerView(frame: .zero)
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        
        return imageView
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(String(describing: Self.self)) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        videoView.cleanup()
        imageView.image = UIImage()
    }
    
    // MARK: - Methods
    func setupCell(with content: Content) {
        switch content.type {
        case .image:
            imageView.isHidden = false
            videoView.isHidden = true
            imageView.setImage(with: content.contentURL)
        case .video:
            videoView.isHidden = false
            imageView.isHidden = true
            videoView.setVideo(with: content.contentURL)
        }
    }
    
    func managePlayingVideo(isPlay: Bool) {
        if isPlay, videoView.queuePlayer?.status == .readyToPlay {
            videoView.queuePlayer?.play()
        } else {
            videoView.queuePlayer?.pause()
        }
    }
    
    private func setupLayout() {
        contentView.addSubview(videoView)
        contentView.addSubview(imageView)
        
        videoView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.height.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.height.equalToSuperview()
        }
    }
}
