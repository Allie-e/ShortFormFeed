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
    private enum Section {
        case content
    }
    
    // MARK: - Properties
    private var contentDataSource: UICollectionViewDiffableDataSource<Section, Content>?
    
    // MARK: - UI
    private let contentCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.decelerationRate = .fast
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        
        return collectionView
    }()
    
    private let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.opacity = 0.6
        view.isHidden = true
        
        return view
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
        setupLayout()
        setupContentCollectionView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        descriptionLabel.numberOfLines = 2
        pageControl.currentPage = 0
        contentCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .left, animated: false)
    }
    
    // MARK: - Methods
    func setupCell(with post: Post) {
        updateContentCollectionView(with: post.contents)
        setPageController(contentsCount: post.contents.count)
        likeLabel.text = post.likeCount.toK()
        followLabel.text = post.user.followCount.toK()
        userImgageView.setImage(with: post.user.profileThumbnailURL)
        userNameLabel.text = post.user.displayName
        descriptionLabel.text = post.description
        manageVideo(isPlay: false)
    }
    
    func setBackgroundOpacity(with alpha: Float) {
        [likeButton, likeLabel, followButton, followLabel, moreButton, userImgageView, userNameLabel, bottomStackView].forEach { view in
            view.layer.opacity = alpha
        }
    }
    
    func manageVideo(isPlay: Bool) {
        contentCollectionView.visibleCells.forEach { cell in
            guard let cell = cell as? ContentCell else { return }
            cell.managePlayingVideo(isPlay: isPlay)
        }
    }
    
    private func setPageController(contentsCount: Int) {
        pageControl.isHidden = contentsCount == 1
        pageControl.numberOfPages = contentsCount
    }
    
    private func addGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(showLabel))
        descriptionLabel.addGestureRecognizer(gesture)
    }
    
    private func setupContentCollectionView() {
        contentCollectionView.register(ContentCell.self)
        setContentCollectionViewDataSource()
        contentCollectionView.delegate = self
    }
    
    private func setContentCollectionViewDataSource() {
        contentDataSource = UICollectionViewDiffableDataSource<Section, Content>(
            collectionView: contentCollectionView
        ) { collectionView, indexPath, content in
            guard let cell = collectionView.dequeueReusableCell(ContentCell.self, for: indexPath) else {
                return UICollectionViewCell()
            }
            
            cell.setupCell(with: content)
            
            return cell
        }
        
        contentCollectionView.dataSource = contentDataSource
    }
    
    private func updateContentCollectionView(with content: [Content]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Content>()
        snapshot.appendSections([.content])
        snapshot.appendItems(content)
        contentDataSource?.apply(snapshot)
    }
    
    private func setupLayout() {
        contentView.addSubview(contentCollectionView)
        contentCollectionView.snp.makeConstraints { make in
            make.edges.height.width.equalToSuperview()
        }
        
        contentView.addSubview(dimView)
        dimView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        [likeButton, likeLabel, followButton, followLabel, moreButton, userImgageView, userNameLabel, bottomStackView].forEach { view in
            contentView.addSubview(view)
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
    
    // MARK: - @objc Method
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
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PostCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
}

// MARK: - UICollectionViewDelegate
extension PostCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? ContentCell else { return }
        cell.managePlayingVideo(isPlay: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? ContentCell else { return }
        cell.managePlayingVideo(isPlay: false)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
}
