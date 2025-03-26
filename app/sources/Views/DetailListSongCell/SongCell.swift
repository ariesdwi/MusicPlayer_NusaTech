//
//  ExplorePageViewController.swift
//  InstagramCloning_Uikit
//
//  Created by Aries Prasetyo on 22/03/25.
//

import UIKit

class SongCell: UITableViewCell {
    static let identifier = "SongCell"

    private let artworkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let artistLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .gray
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(artworkImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(artistLabel)

        NSLayoutConstraint.activate([
            artworkImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            artworkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            artworkImageView.widthAnchor.constraint(equalToConstant: 50),
            artworkImageView.heightAnchor.constraint(equalToConstant: 50),

            titleLabel.leadingAnchor.constraint(equalTo: artworkImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),

            artistLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            artistLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            artistLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            artistLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with viewModel: SongCellViewModel) {
        titleLabel.text = viewModel.title
        artistLabel.text = viewModel.artist
        if let artworkURL = viewModel.artworkURL {
            artworkImageView.loadImage(from: artworkURL, placeholder: UIImage(systemName: "music.note"))
        }
    }
}


