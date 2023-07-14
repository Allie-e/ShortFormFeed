//
//  Feed.swift
//  ShortFormFeed
//
//  Created by Allie on 2023/07/14.
//

import Foundation

struct Feed: Decodable {
    let count: Int
    let page: Int
    let posts: [Post]
}
