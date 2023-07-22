//
//  PostViewModel.swift
//  ShortFormFeed
//
//  Created by Allie on 2023/07/16.
//

import RxSwift

final class PostViewModel: ViewModelDescribing {
    struct Input {
        let viewDidLoadObservable: Observable<Void>
        let refreshObservable: Observable<Void>
        let paginationObservable: Observable<Void>
    }
    
    struct Output {
        let loadPostObservable: Observable<[Post]>
        let errorObservable: Observable<Error>
    }
    
    private let feedAPI = FeedAPI()
    private var pageIndex = 0
    private var posts: [Post]? = []
    
    func transform(_ input: Input) -> Output {
        let postResult = Observable.merge(
            input.viewDidLoadObservable,
            input.refreshObservable
        )
            .withUnretained(self)
            .flatMap { (owner, _) -> Observable<Result<[Post]?, Error>> in
                owner.pageIndex = 0
                return owner.fetchPost(with: owner.pageIndex).asResult()
            }
            .share()
        
        let initPost = postResult
            .withUnretained(self)
            .map { owner, result -> [Post]? in
                switch result {
                case .success(let posts):
                    owner.posts = posts
                    owner.pageIndex += 1
                    return owner.posts
                case .failure:
                    return nil
                }
            }
            .filterNil()
            .share()
        
        let requestError = postResult
            .map { result -> Error? in
                switch result {
                case .success:
                    return nil
                case .failure(let error):
                    return error
                }
            }
            .filterNil()
            .share()
        let paginationPostResult = input.paginationObservable
            .withUnretained(self)
            .flatMap { (owner, _) -> Observable<Result<[Post]?, Error>> in
                return owner.fetchPost(with: owner.pageIndex).asResult()
            }
            .share()
        
        let paginationPost = paginationPostResult
            .withUnretained(self)
            .map { owner, result -> [Post]? in
                switch result {
                case .success(let posts):
                    guard let posts = posts else {
                        return nil
                    }
                    owner.posts?.append(contentsOf: posts)
                    owner.pageIndex += 1
                    return owner.posts
                case .failure:
                    return nil
                }
            }
            .filterNil()
            .share()
        
        let paginationError = postResult
            .map { result -> Error? in
                switch result {
                case .success:
                    return nil
                case .failure:
                    return NetworkError.paginationError
                }
            }
            .filterNil()
            .share()
        
        let post = Observable.merge(initPost, paginationPost)
        let error = Observable.merge(requestError, paginationError)
        
        return Output(
            loadPostObservable: post,
            errorObservable: error
        )
    }
    
    private func fetchPost(with page: Int) -> Observable<[Post]?> {
        return feedAPI.getPost(page: page)
    }
}
