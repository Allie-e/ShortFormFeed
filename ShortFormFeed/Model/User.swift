//
//  User.swift
//  ShortFormFeed
//
//  Created by Allie on 2023/07/14.
//

import Foundation

struct User: Decodable {
    let displayName: String
    let followCount: Int
    let profileThumbnailURL: String

    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case followCount = "follow_count"
        case profileThumbnailURL = "profile_thumbnail_url"
    }
}
