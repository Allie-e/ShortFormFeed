//
//  PostCell.swift
//  ShortFormFeed
//
//  Created by Allie on 2023/07/15.
//

import UIKit
import SnapKit
import AVKit

final class PostCell: UICollectionViewCell {
    static let identifier = String(describing: PostCell.self)
    var videoView: VideoPlayerView?
    
    private let soundButton: UIButton = {
        let button = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 30)
        let image = UIImage(systemName: "speaker.wave.2.fill", withConfiguration: imageConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        
        return button
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 30)
        let image = UIImage(systemName: "heart.fill", withConfiguration: imageConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        
        return button
    }()
    
    private let likeLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textAlignment = .center
        label.textColor = .white
        
        return label
    }()
    
    private let followButton: UIButton = {
        let button = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 30)
        let image = UIImage(systemName: "person.crop.circle.badge.plus", withConfiguration: imageConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        
        return button
    }()
    
    private let followLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textAlignment = .center
        label.textColor = .white
        
        return label
    }()
    
    private let shareButton: UIButton = {
        let button = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 30)
        let image = UIImage(systemName: "ellipsis", withConfiguration: imageConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        
        return button
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCell(with post: Post) {
        self.videoView = VideoPlayerView(frame: .zero, urlStr: post.contents[0].contentURL)
        
        likeLabel.text = post.likeCount.description
        followLabel.text = post.user.followCount.description
        setupLayout()
    }
    
    private func setupLayout() {
        guard let videoView = videoView else { return }
        contentView.addSubview(videoView)
        
        videoView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        [soundButton, likeButton, likeLabel, followButton, followLabel, shareButton].forEach { view in
            contentView.addSubview(view)
        }
        
        soundButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-20)
            make.width.height.equalTo(35)
        }
        
        likeButton.snp.makeConstraints { make in
            make.bottom.equalTo(followButton.snp.top).offset(-40)
            make.width.height.equalTo(35)
            make.centerX.equalTo(shareButton)
        }
        
        likeLabel.snp.makeConstraints { make in
            make.top.equalTo(likeButton.snp.bottom)
            make.trailing.equalTo(likeButton.snp.trailing)
            make.centerX.equalTo(shareButton)
        }
        
        followButton.snp.makeConstraints { make in
            make.bottom.equalTo(shareButton.snp.top).offset(-40)
            make.width.height.equalTo(35)
            make.centerX.equalTo(shareButton)
        }
        
        followLabel.snp.makeConstraints { make in
            make.top.equalTo(followButton.snp.bottom)
            make.trailing.equalTo(followButton.snp.trailing)
            make.centerX.equalTo(shareButton)
        }
        
        shareButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-50)
            make.trailing.equalToSuperview().offset(-20)
            make.width.height.equalTo(35)
        }
    }
}
