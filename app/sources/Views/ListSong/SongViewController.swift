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
    
    private var currentlyPlayingSongId: String? {
        didSet {
            updateAllVisibleCells()
            updateMiniPlayerVisibility()
        }
    }
    
    private var isPlaying = false {
        didSet {
            updateAllVisibleCells()
            miniPlayerView.updatePlayStatus(isPlaying: isPlaying)
        }
    }
    
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
        
        // Add observer for audio interruptions
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioInterruption),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
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
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 78, bottom: 0, right: 16)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        miniPlayerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        view.addSubview(miniPlayerView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            miniPlayerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            miniPlayerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            miniPlayerView.heightAnchor.constraint(equalToConstant: 80), // Updated height
            miniPlayerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        miniPlayerView.delegate = self
    }
    
    // MARK: - ViewModel Binding
    private func bindViewModel() {
        viewModel.$songs
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
                // Reset playback if songs changed
                if self?.currentlyPlayingSongId != nil,
                   !(self?.viewModel.songs.contains { $0.id == self?.currentlyPlayingSongId } ?? false) {
                    self?.stopPlayback()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { isLoading in
                // Handle loading state if needed
            }
            .store(in: &cancellables)
        
        viewModel.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                if let error = error {
                    self?.showErrorAlert(error: error)
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
                    // Handle empty search query if needed
                    // self.viewModel.clearSearch() or similar
                } else {
                    self.viewModel.searchSongs(query: query)
                }
            }
            .store(in: &cancellables)
    }
    
    
    
    @objc private func playerDidFinishPlaying() {
        DispatchQueue.main.async {
            self.isPlaying = false
            self.currentlyPlayingSongId = nil
        }
    }
    
    @objc private func handleAudioInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }
        
        switch type {
        case .began:
            // Interruption began, pause playback
            pausePlayback()
        case .ended:
            // Interruption ended, try to resume if appropriate
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    audioPlayer?.play()
                    isPlaying = true
                }
            }
        @unknown default:
            break
        }
    }
    
    // MARK: - Progress Tracking
    private func startProgressUpdate(duration: TimeInterval) {
        stopProgressUpdate()
        
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.audioPlayer else { return }
            
            let currentTime = player.currentTime().seconds
            let progress = Float(currentTime / duration)
            self.miniPlayerView.updateProgress(progress)
            
            if progress >= 1.0 {
                self.stopProgressUpdate()
                self.playerDidFinishPlaying()
            }
            
        }
    }
    
    private func stopProgressUpdate() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
    
    // MARK: - UI Updates
    private func updateAllVisibleCells() {
        tableView.visibleCells.forEach { cell in
            if let songCell = cell as? SongCell,
               let indexPath = tableView.indexPath(for: songCell),
               indexPath.row < viewModel.songs.count {
                
                let song = viewModel.songs[indexPath.row]
                let shouldAnimate = (song.id == currentlyPlayingSongId) && isPlaying
                songCell.updatePlayingIndicator(isPlaying: shouldAnimate)
            }
        }
    }
    
    private func updateMiniPlayerVisibility() {
        if currentlyPlayingSongId != nil {
            miniPlayerView.showMiniPlayer()
        } else {
            miniPlayerView.hideMiniPlayer()
        }
    }
    
    // MARK: - Helpers
    private func showErrorAlert(error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
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
        let isCurrentlyPlaying = (song.id == currentlyPlayingSongId)
        
        cell.configure(
            with: SongCellViewModel(song: song),
            isPlaying: isCurrentlyPlaying && isPlaying
        )
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension SongViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let song = viewModel.songs[indexPath.row]
        
        if song.id == currentlyPlayingSongId {
            // Toggle play/pause for current song
            if isPlaying {
                pausePlayback()
            } else {
                isPlaying = true
                audioPlayer?.play()
            }
        } else {
            // Play new song
            playSong(song)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
}

// MARK: - UISearchResultsUpdating
extension SongViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        searchTextSubject.send(query)
    }
}

// MARK: - Playback Control Methods
extension SongViewController {
    private func playSong(_ song: Song) {
        audioPlayer?.pause()
        audioPlayer = AVPlayer(url: song.previewURL)
        currentlyPlayingSongId = song.id
        isPlaying = true
        audioPlayer?.play()
        
        // Update mini player
        miniPlayerView.updateSong(title: song.title, artist: song.artist, artworkURL: song.artworkURL)
        miniPlayerView.showMiniPlayer()
        
        // Setup progress tracking
        let duration = CMTimeGetSeconds(audioPlayer?.currentItem?.asset.duration ?? CMTime.zero)
        startProgressUpdate(duration: duration)
    }
    
    private func pausePlayback() {
        audioPlayer?.pause()
        isPlaying = false
    }
    
    private func stopPlayback() {
        audioPlayer?.pause()
        currentlyPlayingSongId = nil
        isPlaying = false
    }
    
    // Add this method to handle playback resuming
    private func resumePlayback() {
        guard currentlyPlayingSongId != nil else { return }
        isPlaying = true
        audioPlayer?.play()
    }
}

// MARK: - MiniPlayerViewDelegate
extension SongViewController: MiniPlayerViewDelegate {
    func didTapPlayPause() {
        if isPlaying {
            pausePlayback()
        } else {
            resumePlayback() // Now this will work
        }
    }
    
    func didTapStop() {
        stopPlayback()
    }
    
    func didNextSong() {
        guard !viewModel.songs.isEmpty, let currentId = currentlyPlayingSongId else { return }
        if let currentIndex = viewModel.songs.firstIndex(where: { $0.id == currentId }) {
            let nextIndex = (currentIndex + 1) % viewModel.songs.count
            playSong(viewModel.songs[nextIndex])
        }
    }
    
    func didPrevSong() {
        guard !viewModel.songs.isEmpty, let currentId = currentlyPlayingSongId else { return }
        if let currentIndex = viewModel.songs.firstIndex(where: { $0.id == currentId }) {
            let prevIndex = (currentIndex - 1 + viewModel.songs.count) % viewModel.songs.count
            playSong(viewModel.songs[prevIndex])
        }
    }
}
