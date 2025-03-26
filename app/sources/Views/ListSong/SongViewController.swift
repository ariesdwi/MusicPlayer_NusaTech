//
//  ViewController.swift
//  InstagramCloning_Uikit
//
//  Created by Aries Prasetyo on 27/02/25.
//


import UIKit
import Combine
import AVFoundation
import Domain

final class SongViewController: UIViewController {
    private let tableView = UITableView()
    private let searchController = UISearchController(searchResultsController: nil)
    private let miniPlayerView = MiniPlayerView()
    
    private let viewModel: SongViewModel
    private var cancellables = Set<AnyCancellable>()
    private var searchTextSubject = PassthroughSubject<String, Never>()

    private var audioPlayer: AVPlayer?
    private var progressTimer: Timer?

    // MARK: - Init
    init(viewModel: SongViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        setupSearchBinding()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        title = "Playlist"
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
        
        searchController.searchBar.placeholder = "Search Songs"
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
        
        tableView.register(SongCell.self, forCellReuseIdentifier: SongCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        miniPlayerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        view.addSubview(miniPlayerView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            miniPlayerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 26),
            miniPlayerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -26),
            miniPlayerView.heightAnchor.constraint(equalToConstant: 100),
            miniPlayerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 100) 
        ])
        
        miniPlayerView.delegate = self
    }
    
    // MARK: - ViewModel Binding
    private func bindViewModel() {
        viewModel.$songs
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.tableView.reloadData() }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { isLoading in
                print("Loading: \(isLoading)")
            }
            .store(in: &cancellables)
        
        viewModel.$error
            .receive(on: DispatchQueue.main)
            .sink { error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Search Binding
    private func setupSearchBinding() {
        searchTextSubject
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard let self = self else { return }
                if query.isEmpty {
                    // self.viewModel.songs = []
                } else {
                    self.viewModel.searchSongs(query: query)
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Play & Stop Music
    
    private func stopSongPreview() {
        audioPlayer?.pause()
        hideMiniPlayer()
    }
    
    private func playSongPreview(url: URL, title: String) {
        stopSongPreview()
        
        audioPlayer = AVPlayer(url: url)
        audioPlayer?.play()
        showMiniPlayer(with: title)

        let duration = CMTimeGetSeconds((audioPlayer?.currentItem?.asset.duration) ?? CMTime.zero)
        startProgressUpdate(duration: duration)
    }
    
    private func stopProgressUpdate() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
    
    private func startProgressUpdate(duration: TimeInterval) {
        stopProgressUpdate()
        
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.audioPlayer else { return }
            let currentTime = player.currentTime().seconds
            let progress = Float(currentTime / duration)
            self.miniPlayerView.updateProgress(progress)
            
            if progress >= 1.0 {
                self.stopSongPreview()
            }
        }
    }
    
    // MARK: - Mini Player Animations
    
    private func showMiniPlayer(with title: String) {
        miniPlayerView.updateSong(title: title)
        UIView.animate(withDuration: 0.3) {
            self.miniPlayerView.transform = CGAffineTransform(translationX: 0, y: -100) // Move up
        }
    }
    
    private func hideMiniPlayer() {
        UIView.animate(withDuration: 0.3) {
            self.miniPlayerView.transform = CGAffineTransform(translationX: 0, y: 100) // Move down
        }
    }
}

// MARK: - UITableViewDataSource
extension SongViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SongCell.identifier, for: indexPath) as! SongCell
        let song = viewModel.songs[indexPath.row]
        let cellViewModel = SongCellViewModel(song: song)
        cell.configure(with: cellViewModel, isPlaying: true)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension SongViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let song = viewModel.songs[indexPath.row]
        
        playSongPreview(url: song.previewURL, title: song.title)
    }
}

// MARK: - UISearchResultsUpdating
extension SongViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        searchTextSubject.send(query)
    }
}

// MARK: - MiniPlayerNotificationViewDelegate
extension SongViewController: MiniPlayerViewDelegate {
    func didNextSong() {
        guard !viewModel.songs.isEmpty else { return }
        
        let currentURL = (audioPlayer?.currentItem?.asset as? AVURLAsset)?.url
        guard let currentIndex = viewModel.songs.firstIndex(where: { $0.previewURL == currentURL }) else { return }
        
        let nextIndex = (currentIndex + 1) % viewModel.songs.count
        let nextSong = viewModel.songs[nextIndex]
        
        playSongPreview(url: nextSong.previewURL, title: nextSong.title)
    }

    func didPrevSong() {
        guard !viewModel.songs.isEmpty else { return }
        
        let currentURL = (audioPlayer?.currentItem?.asset as? AVURLAsset)?.url
        guard let currentIndex = viewModel.songs.firstIndex(where: { $0.previewURL == currentURL }) else { return }
        
        let prevIndex = (currentIndex - 1 + viewModel.songs.count) % viewModel.songs.count
        let prevSong = viewModel.songs[prevIndex]
        
        playSongPreview(url: prevSong.previewURL, title: prevSong.title)
    }


    
    func didTapPlay() {
        if let player = audioPlayer {
            if player.timeControlStatus == .playing {
                player.pause()
            } else {
                player.play()
            }
        }
    }
    
    func didTapStop() {
        stopSongPreview()
    }
}
