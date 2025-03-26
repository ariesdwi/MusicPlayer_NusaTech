//
//  PlayView.swift
//  MusicPlayer_Nusatech
//
//  Created by Aries Prasetyo on 26/03/25.
//


import UIKit

protocol MiniPlayerViewDelegate: AnyObject {
    func didTapPlayPause()
    func didTapStop()
    func didNextSong()
    func didPrevSong()
}

final class MiniPlayerView: UIView {
    
    // MARK: - UI Components
    private lazy var artworkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.image = UIImage(systemName: "music.note")
        imageView.tintColor = .lightGray
        imageView.backgroundColor = .systemGray6
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Not Playing"
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .darkText
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var artistLabel: UILabel = {
        let label = UILabel()
        label.text = "Artist"
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .gray
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "forward.fill"), for: .normal)
        button.tintColor = .darkText
        button.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var previousButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "backward.fill"), for: .normal)
        button.tintColor = .darkText
        button.addTarget(self, action: #selector(prevTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.progressTintColor = .systemBlue
        progress.trackTintColor = .systemGray5
        progress.progress = 0
        return progress
    }()
    
    private lazy var textStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, artistLabel])
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .leading
        return stack
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [previousButton, playPauseButton, nextButton])
        stack.axis = .horizontal
        stack.spacing = 20
        stack.distribution = .equalSpacing
        stack.alignment = .center
        return stack
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [artworkImageView, textStackView, buttonStackView])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var containerStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [mainStackView, progressView])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Properties
    weak var delegate: MiniPlayerViewDelegate?
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        addSubview(containerStackView)
        
        NSLayoutConstraint.activate([
            // Artwork image constraints
            artworkImageView.widthAnchor.constraint(equalToConstant: 50),
            artworkImageView.heightAnchor.constraint(equalTo: artworkImageView.widthAnchor),
            
            // Play button constraints
            playPauseButton.widthAnchor.constraint(equalToConstant: 50),
            playPauseButton.heightAnchor.constraint(equalTo: playPauseButton.widthAnchor),
            
            // Container stack constraints
            containerStackView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            containerStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            containerStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            containerStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
    
    private func setupAppearance() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 6
        clipsToBounds = false
        
        // Initial hidden state
        alpha = 0
        transform = CGAffineTransform(translationX: 0, y: 100)
    }
    
    // MARK: - Public Methods
    func updateSong(title: String, artist: String, artworkURL: URL? = nil) {
        titleLabel.text = title
        artistLabel.text = artist
        
        if let artworkURL = artworkURL {
            artworkImageView.loadImage(from: artworkURL, placeholder: UIImage(systemName: "music.note"))
        } else {
            artworkImageView.image = UIImage(systemName: "music.note")
            artworkImageView.tintColor = .lightGray
        }
    }
    
    func updatePlayStatus(isPlaying: Bool) {
        let imageName = isPlaying ? "pause.fill" : "play.fill"
        playPauseButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    func updateProgress(_ progress: Float) {
        progressView.setProgress(progress, animated: true)
    }
    
    func showMiniPlayer() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.alpha = 1
            self.transform = .identity
        })
    }
    
    func hideMiniPlayer() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0
            self.transform = CGAffineTransform(translationX: 0, y: 100)
        }
    }
    
    // MARK: - Button Actions
    @objc private func playPauseTapped() {
        delegate?.didTapPlayPause()
    }
    
    @objc private func nextTapped() {
        delegate?.didNextSong()
    }
    
    @objc private func prevTapped() {
        delegate?.didPrevSong()
    }
}

