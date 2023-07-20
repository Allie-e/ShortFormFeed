//
//  PostViewModel.swift
//  ShortFormFeed
//
//  Created by Allie on 2023/07/16.
//

import UIKit

import RxSwift

final class PostViewModel: ViewModelDescribing {
    private let feedAPI = FeedAPI()
    
    struct Input {
        let viewDidLoadObservable: Observable<Void>
        let refreshObservable: Observable<Void>
    }
    
    struct Output {
        let loadPostObservable: Observable<Feed>
        let errorObservable: Observable<Error>
    }
    
    func transform(_ input: Input) -> Output {
        let postResult = Observable.merge(
                input.viewDidLoadObservable,
                input.refreshObservable
            )
            .withUnretained(self)
            .flatMap { (owner, _) -> Observable<Result<Feed?, Error>> in
                return owner.fetchPost(with: 1).asResult()
            }
            .share()
        
        let post = postResult
            .map { result -> Feed? in
                switch result {
                case .success(let feed):
                    return feed
                case .failure:
                    return nil
                }
            }
            .filterNil()
            .share()
        
        let error = postResult
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
        
        return Output(
            loadPostObservable: post,
            errorObservable: error
        )
    }
    
    private func fetchPost(with page: Int) -> Observable<Feed?> {
        return feedAPI.getPost(page: page)
    }
}
