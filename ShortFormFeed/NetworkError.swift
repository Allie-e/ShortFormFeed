//
//  NetworkError.swift
//  ShortFormFeed
//
//  Created by Allie on 2023/07/13.
//

import Foundation

enum NetworkError: Error {
    case invalidEndPoint
    case invalidRequest

    var description: String {
        switch self {
        case .invalidEndPoint:
            return "ERROR: Invalid EndPoint"
        case .invalidRequest:
            return "ERROR: Invalid Request"
        }
    }
}
