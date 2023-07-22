//
//  PostCell.swift
//  ShortFormFeed
//
//  Created by Allie on 2023/07/15.
//

import UIKit
import AVKit

import SnapKit

final class PostCell: UICollectionViewCell {
    // MARK: - Properties
    weak var contentStackViewWidth: Constraint?
    var videoView: VideoPlayerView?
    private let wrapperView = UIView()
    private let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.opacity = 0.6
        view.isHidden = true
        
        return view
    }()
    
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
    
    private let moreButton: UIButton = {
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
    
    private let bottomStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        
        return stackView
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .white
        label.numberOfLines = 2
        label.isUserInteractionEnabled = true
        
        return label
    }()
    
    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.white
        
        return pageControl
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        addGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        descriptionLabel.numberOfLines = 2
    }
    
    // MARK: - Methods
    func setupCell(with post: Post) {
        // foreach 뷰를 여러개 만들어서 스크롤뷰에 넣자
        setContentsView(with: post.contents[0])
        setupLayout()
        setPageController(contentsCount: post.contents.count)
        
        likeLabel.text = post.likeCount.toK()
        followLabel.text = post.user.followCount.toK()
        userImgageView.setImage(with: post.user.profileThumbnailURL)
        userNameLabel.text = post.user.displayName
        descriptionLabel.text = post.description
    }
    
    func setBackgroundOpacity(with alpha: Float) {
        wrapperView.layer.opacity = alpha
    }
    
    private func setPageController(contentsCount: Int) {
        pageControl.isHidden = contentsCount == 1
        pageControl.numberOfPages = contentsCount
    }
    
    private func setContentsView(with content: Content) {
        switch content.type {
        case .video:
            videoView = VideoPlayerView(frame: .zero, urlString: content.contentURL)
            guard let videoView = videoView else { return }
            contentView.addSubview(videoView)
            videoView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        case .image:
            imageView.setImage(with: content.contentURL)
            contentView.addSubview(imageView)
            imageView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
    
    private func createImageView(with url: String, frame: CGRect) -> UIImageView {
        let imageView = UIImageView(frame: frame)
        imageView.contentMode = .scaleAspectFill
        imageView.setImage(with: url)
        
        return imageView
    }
    
    func addGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(showLabel))
        descriptionLabel.addGestureRecognizer(gesture)
    }
    
    @objc func showLabel() {
        descriptionLabel.numberOfLines = 0
        let labelHeight = descriptionLabel.frame.height
        let labelIntrinsicHeight = descriptionLabel.intrinsicContentSize.height
        
        if labelHeight < labelIntrinsicHeight {
            descriptionLabel.numberOfLines = 0
            dimView.isHidden = false
        } else {
            descriptionLabel.numberOfLines = 2
            dimView.isHidden = true
        }
    }
    
    private func setupLayout() {
        contentView.addSubview(dimView)
        
        dimView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.addSubview(wrapperView)
        
        wrapperView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        [likeButton, likeLabel, followButton, followLabel, moreButton, userImgageView, userNameLabel, bottomStackView].forEach { view in
            wrapperView.addSubview(view)
        }
        
        bottomStackView.addArrangedSubview(descriptionLabel)
        bottomStackView.addArrangedSubview(pageControl)
        
        likeButton.snp.makeConstraints { make in
            make.bottom.equalTo(followButton.snp.top).offset(-40)
            make.width.height.equalTo(35)
            make.centerX.equalTo(moreButton)
        }
        
        likeLabel.snp.makeConstraints { make in
            make.top.equalTo(likeButton.snp.bottom)
            make.trailing.equalTo(likeButton.snp.trailing)
            make.centerX.equalTo(moreButton)
        }
        
        followButton.snp.makeConstraints { make in
            make.bottom.equalTo(moreButton.snp.top).offset(-40)
            make.width.height.equalTo(35)
            make.centerX.equalTo(moreButton)
        }
        
        followLabel.snp.makeConstraints { make in
            make.top.equalTo(followButton.snp.bottom)
            make.trailing.equalTo(followButton.snp.trailing)
            make.centerX.equalTo(moreButton)
        }
        
        moreButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-150)
            make.trailing.equalToSuperview().offset(-20)
            make.width.height.equalTo(35)
        }
        
        userImgageView.snp.makeConstraints { make in
            make.bottom.equalTo(descriptionLabel.snp.top).offset(-10)
            make.leading.equalToSuperview().offset(20)
            make.width.height.equalTo(40)
        }
        
        userNameLabel.snp.makeConstraints { make in
            make.bottom.equalTo(bottomStackView.snp.top).offset(-10)
            make.leading.equalTo(userImgageView.snp.trailing).offset(10)
            make.centerY.equalTo(userImgageView.snp.centerY)
        }
        
        bottomStackView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(32)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
}
