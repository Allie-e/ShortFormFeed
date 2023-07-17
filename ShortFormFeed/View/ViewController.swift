//
//  ViewController.swift
//  ShortFormFeed
//
//  Created by Allie on 2023/07/11.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    private typealias DiffableDataSource = UICollectionViewDiffableDataSource<Section, FeedItem>
    
    private enum Section {
        case main
    }
    
    private enum FeedItem: Hashable {
        case post(Post)
    }
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        configureDataSource()
        bind()
    }
    
    private func bind() {
        let input = PostViewModel.Input(viewDidLoadObservable: .just(Void()))
        let output = viewModel.transform(input)
        
        output.loadPostObservable
            .withUnretained(self)
            .subscribe(onNext: { owner, feed in
                guard let feed = feed else { return }
                owner.applySnapshot(with: feed.posts)
                print(feed)
            })
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .withUnretained(self)
            .subscribe(onNext: { owner, indexPath in
                guard let cell = owner.collectionView.cellForItem(at: indexPath) as? PostCell else { return }
                cell.soundOff()
            })
            .disposed(by: disposeBag)
    }

    private func setupCollectionView() {
        self.view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        collectionView.decelerationRate = .fast
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.isPagingEnabled = true
    }
    
    private func configureDataSource() {
        collectionView.register(PostCell.self)
        
        dataSource = DiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
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
    
    private func startLoop() {
        let _ = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            self.moveNextPage()
        }
    }
    
    private func moveNextPage() {
        let itemCount = collectionView.numberOfItems(inSection: 0)
        
        nowPage += 1
        if nowPage >= itemCount {
            nowPage = 0
        }
        
        collectionView.scrollToItem(at: IndexPath(item: nowPage, section: 0), at: .centeredVertically, animated: true)
    }
}
