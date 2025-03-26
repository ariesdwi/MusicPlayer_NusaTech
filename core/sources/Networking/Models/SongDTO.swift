//
//  SongDTO.swift
//  MusicPlayer_Nusatech
//
//  Created by Aries Prasetyo on 25/03/25.
//

import Foundation

public struct SongResponseDTO: Decodable {
    public let resultCount: Int
    public let results: [SongDTO]
}

public struct SongDTO: Decodable {
    public let trackId: Int
    public let trackName: String
    public let artistName: String
    public let previewUrl: String?
    public let artworkUrl100: String?
    
    private enum CodingKeys: String, CodingKey {
        case trackId, trackName, artistName, previewUrl, artworkUrl100
    }
}
