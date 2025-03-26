//
//  MusicPlayerViewModel.swift
//  MusicPlayer_Nusatech
//
//  Created by Aries Prasetyo on 25/03/25.
//


import Foundation
import Combine
import Domain

public final class SongViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published public private(set) var songs: [Song] = []
    @Published public private(set) var isLoading = false
    @Published public private(set) var error: NetworkError?
    
    // MARK: - Dependencies
    private let searchSongsUseCase: SearchSongsUseCase
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    public init(searchSongsUseCase: SearchSongsUseCase) {
        self.searchSongsUseCase = searchSongsUseCase
    }
    
    // MARK: - Methods
    public func searchSongs(query: String) {
        isLoading = true
        error = nil
        
        searchSongsUseCase.execute(query: query)
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



