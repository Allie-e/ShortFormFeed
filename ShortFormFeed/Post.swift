//
//  Post.swift
//  ShortFormFeed
//
//  Created by Allie on 2023/07/14.
//

import Foundation

struct Post: Decodable {
    let contents: [Content]
    let description: String
    let id: String
    let user: User
    let likeCount: Int

    enum CodingKeys: String, CodingKey {
        case contents, description, id, user
        case likeCount = "like_count"
    }
}
