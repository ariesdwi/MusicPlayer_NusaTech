//
//  NetworkService.swift
//  MusicPlayer_Nusatech
//
//  Created by Aries Prasetyo on 25/03/25.
//

import Foundation

public struct Song: Equatable {
    public let id: String
    public let title: String
    public let artist: String
    public let previewURL: URL
    public let artworkURL: URL

    public init?(id: String, title: String, artist: String, previewURL: String, artworkURL: String) {
        guard let previewURL = URL(string: previewURL), let artworkURL = URL(string: artworkURL) else {
            return nil // Fails initialization if URLs are invalid
        }
        self.id = id
        self.title = title
        self.artist = artist
        self.previewURL = previewURL
        self.artworkURL = artworkURL
    }
}

