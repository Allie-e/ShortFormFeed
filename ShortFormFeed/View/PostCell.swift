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
    // MARK: - Properties
    static let identifier = String(describing: PostCell.self)
    var videoView: VideoPlayerView?
    let wrapperView = UIView()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        
        return imageView
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
    
    private let userImgageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .white
        
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .white
        label.numberOfLines = 2
        
        return label
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    func setupCell(with post: Post) {
        switch post.contents[0].type {
        case .video:
            self.videoView = VideoPlayerView(frame: .zero, urlString: post.contents[0].contentURL)
            setupLayout(with: .video)
        case .image:
            self.imageView.setImage(with: post.contents[0].contentURL)
            setupLayout(with: .image)
        }
        
        likeLabel.text = post.likeCount.toK()
        followLabel.text = post.user.followCount.toK()
        userImgageView.setImage(with: post.user.profileThumbnailURL)
        userNameLabel.text = post.user.displayName
        descriptionLabel.text = post.description
    }
    
    func setBackgroundOpacity(with alpha: Float) {
        wrapperView.layer.opacity = alpha
    }
        
    private func setupLayout(with type: TypeEnum) {
        switch type {
        case .video:
            guard let videoView = videoView else { return }
            contentView.addSubview(videoView)
            videoView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        case .image:
            contentView.addSubview(imageView)
            imageView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        
        contentView.addSubview(wrapperView)
        
        wrapperView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        [likeButton, likeLabel, followButton, followLabel, shareButton, userImgageView, userNameLabel, descriptionLabel].forEach { view in
            wrapperView.addSubview(view)
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
            make.bottom.equalTo(userImgageView.snp.top).offset(-10)
            make.trailing.equalToSuperview().offset(-20)
            make.width.height.equalTo(35)
        }
        
        userImgageView.snp.makeConstraints { make in
            make.bottom.equalTo(descriptionLabel.snp.top).offset(-10)
            make.leading.equalToSuperview().offset(20)
            make.width.height.equalTo(40)
        }
        
        userNameLabel.snp.makeConstraints { make in
            make.bottom.equalTo(descriptionLabel.snp.top).offset(-10)
            make.leading.equalTo(userImgageView.snp.trailing).offset(10)
            make.centerY.equalTo(userImgageView.snp.centerY)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-40)
        }
    }
}
