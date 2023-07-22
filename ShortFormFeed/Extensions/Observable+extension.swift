//
//  Observable+extension.swift
//  ShortFormFeed
//
//  Created by Allie on 2023/07/20.
//

import Foundation

import RxSwift

extension ObservableType {
  func asResult() -> Observable<Result<Element, Error>> {
    return self.map { .success($0) }
      .catch { .just(.failure($0)) }
  }
}

extension Observable {
  func filterNil<U>() -> Observable<U> where Element == U? {
    return filter { $0 != nil }.map { $0! }
  }
}
