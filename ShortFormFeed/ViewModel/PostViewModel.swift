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
    }
    
    struct Output {
        let loadPostObservable: Observable<Feed?>
    }
    
    func transform(_ input: Input) -> Output {
        let post = input.viewDidLoadObservable
            .withUnretained(self)
            .flatMap { (owner, _) -> Observable<Feed?> in
                return owner.fetchPost(with: 1)
            }
        
        return Output(loadPostObservable: post)
    }
    
    private func fetchPost(with page: Int) -> Observable<Feed?> {
        return feedAPI.getPost(page: page)
    }
}
