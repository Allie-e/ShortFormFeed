//
//  NetworkError.swift
//  ShortFormFeed
//
//  Created by Allie on 2023/07/13.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidRequest
    case paginationError

    var description: String {
        switch self {
        case .invalidURL:
            return "ERROR: Invalid URL"
        case .invalidRequest:
            return "ERROR: Invalid Request"
        case .paginationError:
            return "ERROR: Pagination Error"
        }
    }
}
