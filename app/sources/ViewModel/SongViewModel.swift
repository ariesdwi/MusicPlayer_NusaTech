//
//  MusicPlayerViewModel.swift
//  MusicPlayer_Nusatech
//
//  Created by Aries Prasetyo on 25/03/25.
//


import Foundation
import Combine
import Core

public final class SongViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published public private(set) var songs: [Song] = []
    @Published public private(set) var isLoading = false
    @Published public private(set) var error: NetworkError?
    
    // MARK: - Dependencies
    private let networkService: NetworkService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    public init(networkService: NetworkService = APIClient()) {
        self.networkService = networkService
    }
    
    // MARK: - Public Methods
    public func searchSongs(query: String, type: EntityType = .song, page: Int? = nil, limit: Int? = 20) {
        isLoading = true
        error = nil
        
        let endpoint = MusicAPI.searchSongs(searchTerm: query, type: type, page: page, limit: limit)
        
        guard let request = endpoint.urlRequest else {
            self.isLoading = false
            self.error = .invalidRequest
            return
        }
        
        networkService.request(request, responseType: SongResponseDTO.self)
            .map { response in
                response.results.compactMap { dto in
                    guard let previewURL = URL(string: dto.previewUrl ?? ""),
                          let artworkURL = URL(string: dto.artworkUrl100 ?? "") else {
                        return nil
                    }
                    
                    return Song(
                        id: dto.trackId,
                        title: dto.trackName,
                        artist: dto.artistName,
                        previewURL: previewURL,
                        artworkURL: artworkURL
                    )
                }
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.error = error
                    }
                },
                receiveValue: { [weak self] songs in
                    self?.songs = songs
                }
            )
            .store(in: &cancellables)
    }


}



