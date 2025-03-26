//
//  APIClient.swift
//  MusicPlayer_Nusatech
//
//  Created by Aries Prasetyo on 25/03/25.
//

import Combine
import Core
import Foundation

public final class SearchSongsUseCase {
    public init() {}
    
    public func execute(query: String, type: EntityType = .song, page: Int? = nil, limit: Int? = 20) -> AnyPublisher<[Song], NetworkError> {
        
        let endpoint = MusicAPI.searchSongs(searchTerm: query, type: type, page: page, limit: limit)
        
        guard let request = endpoint.urlRequest else {
            return Fail(error: .invalidRequest).eraseToAnyPublisher()
        }
        
        return APIClient.shared.request(request, responseType: SongResponseDTO.self)
            .map { dto in
                dto.results.compactMap { result in
                    guard let previewURL = URL(string: result.previewUrl ?? ""),
                          let artworkURL = URL(string: result.artworkUrl100 ?? "") else {
                        return nil
                    }
                    
                    return Song(
                        id: result.trackId,
                        title: result.trackName,
                        artist: result.artistName,
                        previewURL: previewURL,
                        artworkURL: artworkURL
                    )
                }
            }
            .eraseToAnyPublisher()
    }
}


