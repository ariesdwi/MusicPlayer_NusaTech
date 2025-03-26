//
//  Endpoints.swift
//  MusicPlayer_Nusatech
//
//  Created by Aries Prasetyo on 25/03/25.
//


import Alamofire
import Foundation

// MARK: - Entity Type Enum
public enum EntityType: String {
    case album
    case artist
    case song
}

// MARK: - Endpoint Protocol
public protocol Endpoint {
    var urlRequest: URLRequest? { get }
}

// MARK: - API Endpoint Implementation
public struct APIEndpoint: Endpoint {
    private let baseURL: String
    private let path: String
    private let method: HTTPMethod
    private let parameters: [String: String]
    
    public init(baseURL: String, path: String, method: HTTPMethod, parameters: [String: String]) {
        self.baseURL = baseURL
        self.path = path
        self.method = method
        self.parameters = parameters
    }
    
    public var urlRequest: URLRequest? {
        guard let url = RequestBuilder.createURL(baseURL: baseURL, path: path, parameters: parameters) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.method = method
        return request
    }
}

// MARK: - Request Builder (SRP)
public struct RequestBuilder {
    public static func createURL(baseURL: String, path: String, parameters: [String: String]) -> URL? {
        var components = URLComponents(string: baseURL + path)
        components?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        return components?.url
    }
}

// MARK: - Music API Endpoints
public enum MusicAPI {
    public static func searchSongs(searchTerm: String, type: EntityType, page: Int?, limit: Int?) -> APIEndpoint {
        var params: [String: String] = [
            "term": searchTerm,
            "entity": type.rawValue
        ]
        
        if let page = page, let limit = limit {
            let offset = page * limit
            params["limit"] = String(limit)
            params["offset"] = String(offset)
        }
        
        return APIEndpoint(
            baseURL: "https://itunes.apple.com",
            path: "/search",
            method: .get,
            parameters: params
        )
    }
}

