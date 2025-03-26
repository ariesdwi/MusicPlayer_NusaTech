//
//  SongCellViewModel.swift
//  MusicPlayer_Nusatech
//
//  Created by Aries Prasetyo on 26/03/25.
//

import Foundation
import Domain

struct SongCellViewModel {
    let title: String
    let artist: String
    let artworkURL: URL?

    init(song: Song) {
        self.title = song.title
        self.artist = song.artist
        self.artworkURL = song.artworkURL
    }
}
