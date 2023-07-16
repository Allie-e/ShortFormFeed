//
//  ViewModelDescribing.swift
//  ShortFormFeed
//
//  Created by Allie on 2023/07/16.
//

import Foundation

protocol ViewModelDescribing {
    associatedtype Input
    associatedtype Output

    func transform(_ input: Input) -> Output
}
