//
//  Content.swift
//  ShortFormFeed
//
//  Created by Allie on 2023/07/14.
//

import Foundation

struct Content: Decodable {
    let contentURL: String
    let type: TypeEnum

    enum CodingKeys: String, CodingKey {
        case contentURL = "content_url"
        case type
    }
}

enum TypeEnum: String, Decodable {
    case image = "image"
    case video = "video"
}
