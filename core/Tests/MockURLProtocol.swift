//
//  Untitled.swift
//  MusicPlayer_Nusatech
//
//  Created by Aries Prasetyo on 27/03/25.
//

import Foundation
import XCTest
import Alamofire
@testable import Core

class MockURLProtocol: URLProtocol {
    static var responseData: Data?
    static var response: URLResponse?
    static var error: Error?

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

//    override func startLoading() {
//        if let error = MockURLProtocol.error {
//            client?.urlProtocol(self, didFailWithError: error)
//        } else {
//            if let response = MockURLProtocol.response {
//                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
//            }
//            if let data = MockURLProtocol.responseData {
//                client?.urlProtocol(self, didLoad: data)
//            }
//        }
//        client?.urlProtocolDidFinishLoading(self)
//    }
    override func startLoading() {
        if let error = MockURLProtocol.error as? NetworkError {
            client?.urlProtocol(self, didFailWithError: error)
        } else if let error = MockURLProtocol.error {
            let networkError = NetworkErrorMapper.map(AFError.sessionTaskFailed(error: error as NSError))
            client?.urlProtocol(self, didFailWithError: networkError)
        } else {
            if let response = MockURLProtocol.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let data = MockURLProtocol.responseData {
                client?.urlProtocol(self, didLoad: data)
            }
        }
        client?.urlProtocolDidFinishLoading(self)
    }



    override func stopLoading() {}
}

