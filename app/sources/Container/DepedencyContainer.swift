//
//  DepedencyContainer.swift
//  MusicPlayer_Nusatech
//
//  Created by Aries Prasetyo on 26/03/25.
//

import Foundation
import Core
import Domain

final class DependencyContainer {
    // MARK: - Shared Instances
    private let networkService: NetworkService

    // MARK: - Use Cases
    let searchSongsUseCase: SearchSongsUseCase

    // MARK: - ViewModels
    let songViewModel: SongViewModel

    init() {
        // Initialize shared services
        self.networkService = APIClient()

        // Initialize Use Cases
        self.searchSongsUseCase = SearchSongsUseCase(networkService: networkService)

        // Initialize ViewModels
        self.songViewModel = SongViewModel(searchSongsUseCase: searchSongsUseCase)
    }
}
