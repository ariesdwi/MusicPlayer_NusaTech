//
//  NetworkService.swift
//  MusicPlayer_Nusatech
//
//  Created by Aries Prasetyo on 25/03/25.
//


import Foundation

public struct Song: Equatable {
    public let id: Int
    public let title: String
    public let artist: String
    public let previewURL: URL
    public let artworkURL: URL

    public init(id: Int, title: String, artist: String, previewURL: URL, artworkURL: URL) {
        self.id = id
        self.title = title
        self.artist = artist
        self.previewURL = previewURL
        self.artworkURL = artworkURL
    }
}


