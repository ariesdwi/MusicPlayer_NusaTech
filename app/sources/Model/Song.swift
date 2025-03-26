//
//  Song.swift
//  MusicPlayer_Nusatech
//
//  Created by Aries Prasetyo on 26/03/25.
//

import Foundation

public struct Song: Identifiable {
    public let id: Int
    public let title: String
    public let artist: String
    public let previewURL: URL
    public let artworkURL: URL?
}
