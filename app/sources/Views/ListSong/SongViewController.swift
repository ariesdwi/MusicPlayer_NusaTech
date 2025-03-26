//
//  ViewController.swift
//  InstagramCloning_Uikit
//
//  Created by Aries Prasetyo on 27/02/25.
//

import UIKit
import Combine

final class SongViewController: UIViewController {
    
    private let tableView = UITableView()
    private let searchBar = UISearchBar()

    private let viewModel = SongViewModel()
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.searchSongs(query: "Adele") // Default search
        setupUI()
        bindViewModel()
        
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        tableView.register(SongCell.self, forCellReuseIdentifier: "SongCell")
        tableView.dataSource = self
        
        view.addSubview(tableView)
        tableView.frame = view.bounds
    }
    
    private func bindViewModel() {
        viewModel.$songs
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.tableView.reloadData() }
            .store(in: &cancellables)
    }
}

extension SongViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as! SongCell
        cell.configure(with: viewModel.songs[indexPath.row])
        return cell
    }
}

