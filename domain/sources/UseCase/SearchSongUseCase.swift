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
    private let networkService: NetworkService

    public init(networkService: NetworkService) {
        self.networkService = networkService
    }

    public func execute(query: String, type: EntityType = .song, page: Int? = nil, limit: Int? = 20) -> AnyPublisher<[Song], NetworkError> {
        
        let endpoint = MusicAPI.searchSongs(searchTerm: query, type: type, page: page, limit: limit)
        
        guard let request = endpoint.urlRequest else {
            return Fail(error: .invalidRequest).eraseToAnyPublisher()
        }
        
        return networkService.request(request, responseType: SongResponseDTO.self)
            .map { dto in
                dto.results.compactMap { result in
                    Song(
                        id: String(result.trackId),
                        title: result.trackName,
                        artist: result.artistName,
                        previewURL: result.previewUrl ?? "",
                        artworkURL: result.artworkUrl100 ?? ""
                    )
                }
            }
            .eraseToAnyPublisher()
    }
}



