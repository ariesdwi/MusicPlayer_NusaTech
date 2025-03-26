//
//  NetworkService.swift
//  MusicPlayer_Nusatech
//
//  Created by Aries Prasetyo on 25/03/25.
//

//import Combine
//import Alamofire
//
//public final class MusicService {
//    private let client: APIClient
//    
//    public init(client: APIClient = .shared) {
//        self.client = client
//    }
//    
//    public func searchSongs(query: String) -> AnyPublisher<[Song], Error> {
//        client.request(Endpoint.searchSongs(query: query))
//            .map { (response: SongResponseDTO) in
//                response.results.map { $0.toDomain() }
//            }
//            .eraseToAnyPublisher()
//    }
//}
//
//struct SongResponseDTO: Codable {
//    let results: [SongDTO]
//}
