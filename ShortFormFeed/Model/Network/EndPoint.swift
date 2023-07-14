//
//  EndPoint.swift
//  ShortFormFeed
//
//  Created by Allie on 2023/07/13.
//

import Foundation

enum EndPoint {
    private static let mainPath = "http://ec2-13-124-248-215.ap-northeast-2.compute.amazonaws.com/api/v1/posts"
    
    case page(Int)
    
    var url: URL? {
        switch self {
        case .page(let page):
            var components = URLComponents(string: EndPoint.mainPath)
            let pageQuery = URLQueryItem(name: "page", value: page.description)
            components?.queryItems = [pageQuery]
            
            return components?.url
        }
    }
}
