//
//  ExplorePageViewController.swift
//  InstagramCloning_Uikit
//
//  Created by Aries Prasetyo on 22/03/25.
//\

import UIKit

class SongCell: UITableViewCell {
    static let identifier = "SongCell"
    
    // MARK: - UI Components
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
    
    private let waveformView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 2
        stack.alignment = .center
        stack.distribution = .fillEqually
        stack.isHidden = true
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Animation State
    private var isAnimating = false {
        didSet {
            waveformView.isHidden = !isAnimating
        }
    }
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        createWaveformBars()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        stopWaveformAnimation()
        artworkImageView.image = nil
    }
    
    // MARK: - Configuration
    func configure(with viewModel: SongCellViewModel, isPlaying: Bool) {
        titleLabel.text = viewModel.title
        artistLabel.text = viewModel.artist
        
        if let artworkURL = viewModel.artworkURL {
            artworkImageView.loadImage(from: artworkURL, placeholder: UIImage(systemName: "music.note"))
        }
        
        updatePlayingIndicator(isPlaying: isPlaying)
    }
    
    func updatePlayingIndicator(isPlaying: Bool) {
        if isPlaying {
            startWaveformAnimation()
        } else {
            stopWaveformAnimation()
        }
    }
    
    // MARK: - Private Methods
    private func setupViews() {
        contentView.addSubview(artworkImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(artistLabel)
        contentView.addSubview(waveformView)
        
        NSLayoutConstraint.activate([
            artworkImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            artworkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            artworkImageView.widthAnchor.constraint(equalToConstant: 50),
            artworkImageView.heightAnchor.constraint(equalToConstant: 50),
            
            titleLabel.leadingAnchor.constraint(equalTo: artworkImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: waveformView.leadingAnchor, constant: -8),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            
            artistLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            artistLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            artistLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            artistLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            waveformView.widthAnchor.constraint(equalToConstant: 40),
            waveformView.heightAnchor.constraint(equalToConstant: 20),
            waveformView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            waveformView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    private func createWaveformBars() {
        waveformView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for _ in 0..<5 {
            let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false
            
            let bar = UIView()
            bar.backgroundColor = .systemGreen
            bar.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(bar)
            
            // Critical constraints:
            NSLayoutConstraint.activate([
                container.widthAnchor.constraint(equalToConstant: 4),
                
                // Bar constraints
                bar.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                bar.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                bar.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                bar.heightAnchor.constraint(equalToConstant: 4) // Initial height
            ])
            
            waveformView.addArrangedSubview(container)
        }
    }
    
    private func startWaveformAnimation() {
        guard !isAnimating else { return }
        isAnimating = true
        
        // Animate each bar with different timing
        for (index, container) in waveformView.arrangedSubviews.enumerated() {
            guard let bar = container.subviews.first else { continue }
            
            let delay = Double(index) * 0.15
            let newHeight = CGFloat.random(in: 8...20)
            
            UIView.animate(
                withDuration: 0.5,
                delay: delay,
                options: [.repeat, .autoreverse, .curveEaseInOut],
                animations: {
                    bar.constraints.first(where: { $0.firstAttribute == .height })?.constant = newHeight
                    container.layoutIfNeeded()
                }
            )
        }
    }
    
    private func stopWaveformAnimation() {
        guard isAnimating else { return }
        isAnimating = false
        
        // Reset all animations and bar heights
        waveformView.arrangedSubviews.forEach { container in
            guard let bar = container.subviews.first else { return }
            
            bar.layer.removeAllAnimations()
            UIView.performWithoutAnimation {
                bar.constraints.first(where: { $0.firstAttribute == .height })?.constant = 4
                container.layoutIfNeeded()
            }
        }
    }
}

