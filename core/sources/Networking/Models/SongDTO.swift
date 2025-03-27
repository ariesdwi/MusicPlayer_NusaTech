//
//  SongDTO.swift
//  MusicPlayer_Nusatech
//
//  Created by Aries Prasetyo on 25/03/25.
//

import Foundation

// SongDTO.swift
public struct SongDTO: Decodable {
    public let trackId: Int
    public let trackName: String
    public let artistName: String
    public let previewUrl: String?
    public let artworkUrl100: String?

    public init(trackId: Int, trackName: String, artistName: String, previewUrl: String?, artworkUrl100: String?) {
        self.trackId = trackId
        self.trackName = trackName
        self.artistName = artistName
        self.previewUrl = previewUrl
        self.artworkUrl100 = artworkUrl100
    }
}

// SongResponseDTO.swift
public struct SongResponseDTO: Decodable {
    public let resultCount: Int
    public let results: [SongDTO]

    public init(resultCount: Int, results: [SongDTO]) {
        self.resultCount = resultCount
        self.results = results
    }
}

