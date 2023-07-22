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
    let viewModel = PostViewModel()
    private let disposeBag: DisposeBag = .init()
    private var dataSource: DiffableDataSource?
    private var snapshot = NSDiffableDataSourceSnapshot<Section, FeedItem>()
    private var nowPage = 0
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        return collectionView
    }()
    
    private let refreshButton: UIButton = {
        let button = UIButton()
        button.setTitle("새로고침", for: .normal)
        button.isHidden = true
        button.backgroundColor = .blue
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        configureDataSource()
        bind()
    }
    
    // MARK: - Methods
    private func bind() {
        let paginationObservable = collectionView.rx.didEndDisplayingCell
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .map { owner, args -> Void? in // args.0 == cell, args.1 == indexPath
                let currentCellIndex = CGFloat(args.at.row + 1) // 0부터 시작하니까 1 더해줌 (이전 셀)
                let cellHeight = args.cell.frame.height // 셀 높이
                
                // 전체 500 없어진거 400
                // contentsOffset = 400
                // 400을 구하는 과정
                if (owner.collectionView.contentSize.height - owner.collectionView.frame.height) == currentCellIndex * cellHeight {
                    return Void()
                }
                return nil
            }
            .filterNil()
        
        let input = PostViewModel.Input(
            viewDidLoadObservable: .just(Void()),
            refreshObservable: refreshButton.rx.tap.asObservable(),
            paginationObservable: paginationObservable
        )
        let output = viewModel.transform(input)
        
        output.loadPostObservable
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { owner, posts in
                owner.applySnapshot(with: posts)
                owner.refreshButton.isHidden = true
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
                    owner.refreshButton.isHidden = false
                }
            })
            .disposed(by: disposeBag)
        
        collectionView.rx.contentOffset
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { owner, offset in
                let cellHeight = UIScreen.main.bounds.height
                let row = Int(offset.y / cellHeight)
                let alpha = (offset.y / cellHeight) - CGFloat(row)
                let cell = owner.collectionView.cellForItem(at: IndexPath(row: row, section: 0)) as? PostCell
                cell?.setBackgroundOpacity(with: Float(1 - alpha))
            })
            .disposed(by: disposeBag)
        
        collectionView.rx.willDisplayCell
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { cell, indexPath in
                if let cell = cell as? PostCell {
                    cell.videoView?.queuePlayer?.play()
                }
            })
            .disposed(by: disposeBag)
        
        collectionView.rx.didEndDisplayingCell
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { cell, indexPath in
                if let cell = cell as? PostCell {
                    cell.videoView?.queuePlayer?.pause()
                }
            })
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { owner, indexPath in
                guard let cell = owner.collectionView.cellForItem(at: indexPath) as? PostCell else { return }
                cell.videoView?.manageSound()
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
    
    private func setupCollectionView() {
        self.view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        collectionView.decelerationRate = .fast
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.isPagingEnabled = true
        
        self.view.addSubview(refreshButton)
        refreshButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(100)
        }
    }
    
    private func configureDataSource() {
        collectionView.register(PostCell.self)
        
        dataSource = DiffableDataSource(collectionView: collectionView, cellProvider: { [weak self] collectionView, indexPath, item in
            switch item {
            case .post(let post):
                let cell = collectionView.dequeueReusableCell(PostCell.self, for: indexPath)
                cell?.setupCell(with: post)
                
                return cell
            }
        })
        
        collectionView.dataSource = dataSource
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
