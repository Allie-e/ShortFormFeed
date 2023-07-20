//
//  FeedAPI.swift
//  ShortFormFeed
//
//  Created by Allie on 2023/07/14.
//

import Foundation

import Alamofire
import RxSwift

final class FeedAPI {
    func getPost(page: Int) -> Observable<Feed?> {
        let url = EndPoint.page(page).url
        let posts = fetch(with: url)
            .map { data -> Feed? in
                let decodedData = try? JSONDecoder().decode(Feed.self, from: data)
                
                return decodedData
            }
        
        return posts
    }
    
    func fetch(with url: URL?) -> Observable<Data> {
        guard let url = url else {
            return .error(NetworkError.invalidURL)
        }
        
        return Observable.create { emitter in
            let request = AF.request(url)
                .validate(statusCode: 200..<300)
                .responseData { dataResponse in
                    switch dataResponse.result {
                    case .success(let data):
                        emitter.onNext(data)
                    case .failure(_):
                        emitter.onError(NetworkError.invalidRequest)
                    }
                    emitter.onCompleted()
                }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
}
