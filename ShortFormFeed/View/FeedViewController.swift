//
//  FeedViewController.swift
//  ShortFormFeed
//
//  Created by Allie on 2023/07/11.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit

final class FeedViewController: UIViewController {
    private typealias DiffableDataSource = UICollectionViewDiffableDataSource<Section, FeedItem>
    
    private enum Section {
        case main
    }
    
    private enum FeedItem: Hashable {
        case post(Post)
    }
    
    // MARK: - Properties
    private let viewModel = PostViewModel()
    private let disposeBag: DisposeBag = .init()
    private var dataSource: DiffableDataSource?
    private var snapshot = NSDiffableDataSourceSnapshot<Section, FeedItem>()
    private var nowPage = 0
    
    // MARK: - UI
    private let postCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.bounds.height
        )
        
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collectionView.decelerationRate = .fast
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.isPagingEnabled = true
        
        return collectionView
    }()
    
    private let retryButton: UIButton = {
        let button = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20)
        let image = UIImage(systemName: "arrow.clockwise", withConfiguration: imageConfig)
        button.setTitle(" 다시시도", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.backgroundColor = .darkGray
        button.layer.cornerRadius = 20
        button.imageView?.contentMode = .scaleAspectFit
        button.isHidden = true
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        configureDataSource()
        bind()
        bindCollectionView()
    }
    
    // MARK: - Methods
    private func bind() {
        let paginationObservable = postCollectionView.rx.didEndDisplayingCell
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .map { owner, args -> Void? in
                let currentCellIndex = CGFloat(args.at.row + 1)
                let cellHeight = args.cell.frame.height
                if (owner.postCollectionView.contentSize.height - owner.postCollectionView.frame.height) == currentCellIndex * cellHeight {
                    return Void()
                }
                return nil
            }
            .filterNil()
        
        let input = PostViewModel.Input(
            viewDidLoadObservable: .just(Void()),
            refreshObservable: retryButton.rx.tap.asObservable(),
            paginationObservable: paginationObservable
        )
        let output = viewModel.transform(input)
        
        output.loadPostObservable
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { owner, posts in
                owner.applySnapshot(with: posts)
                owner.retryButton.isHidden = true
            })
            .disposed(by: disposeBag)
        
        output.errorObservable
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { (owner, error) in
                if let error = error as? NetworkError,
                   error == .paginationError
                {
                    owner.showToast(message: "다음 피드를 불러올 수 없습니다.\n 잠시후 다시 시도해주세요.")
                } else {
                    owner.retryButton.isHidden = false
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func bindCollectionView() {
        postCollectionView.rx.contentOffset
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { owner, offset in
                let cellHeight = UIScreen.main.bounds.height
                let row = Int(offset.y / cellHeight)
                let alpha = (offset.y / cellHeight) - CGFloat(row)
                let cell = owner.postCollectionView.cellForItem(at: IndexPath(row: row, section: 0)) as? PostCell
                cell?.setBackgroundOpacity(with: Float(1 - alpha))
            })
            .disposed(by: disposeBag)
        
        postCollectionView.rx.willDisplayCell
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { cell, indexPath in
                if let cell = cell as? PostCell {
                    cell.manageVideo(isPlay: true)
                }
            })
            .disposed(by: disposeBag)
        
        postCollectionView.rx.didEndDisplayingCell
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { cell, indexPath in
                if let cell = cell as? PostCell {
                    cell.manageVideo(isPlay: false)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func showToast(message : String) {
        let toastLabel = UILabel(frame: CGRect(
            x: self.view.frame.size.width/2 - 150,
            y: self.view.frame.size.height - 100,
            width: 300,
            height: 50)
        )
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.numberOfLines = 2
        toastLabel.font = UIFont.systemFont(ofSize: 14.0)
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        
        UIView.animate(
            withDuration: 4.0,
            delay: 0.1,
            options: .curveEaseOut,
            animations: {
                toastLabel.alpha = 0.0
            }, completion: {(isCompleted) in
                toastLabel.removeFromSuperview()
            })
    }
    
    private func setupLayout() {
        self.view.addSubview(postCollectionView)
        
        postCollectionView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        self.view.addSubview(retryButton)
        retryButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalTo(120)
        }
    }
    
    private func configureDataSource() {
        postCollectionView.register(PostCell.self)
        
        dataSource = DiffableDataSource(collectionView: postCollectionView, cellProvider: { [weak self] collectionView, indexPath, item in
            switch item {
            case .post(let post):
                let cell = collectionView.dequeueReusableCell(PostCell.self, for: indexPath)
                cell?.setupCell(with: post)
                
                return cell
            }
        })
        
        postCollectionView.dataSource = dataSource
    }
    
    private func applySnapshot(with posts: [Post]?) {
        guard let posts = posts else { return }
        let postItems = posts.map { FeedItem.post($0) }
        snapshot = NSDiffableDataSourceSnapshot<Section, FeedItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(postItems)
        dataSource?.apply(snapshot)
    }
}
