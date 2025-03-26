//
//  NetworkError.swift
//  MusicPlayer_Nusatech
//
//  Created by Aries Prasetyo on 26/03/25.
//

import Foundation
import Alamofire

public enum NetworkError: Error {
    case invalidURL
    case invalidRequest
    case requestFailed(description: String)
    case invalidResponse(statusCode: Int)
    case decodingFailed(underlyingError: Error)
    case unknown(Error)
    
    static func fromAFError(_ error: AFError) -> NetworkError {
        switch error {
        case .invalidURL: return .invalidURL
        case .responseValidationFailed(let reason):
            if case .unacceptableStatusCode(let code) = reason {
                return .invalidResponse(statusCode: code)
            }
            return .requestFailed(description: error.localizedDescription)
        default: return .unknown(error)
        }
    }
}
