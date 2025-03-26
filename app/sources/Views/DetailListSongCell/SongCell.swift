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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
            
            // 🔵 Playing Indicator Position
            waveformView.widthAnchor.constraint(equalToConstant: 40),
            waveformView.heightAnchor.constraint(equalToConstant: 20),
            waveformView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            waveformView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            
        ])
        
        createWaveformBars()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with viewModel: SongCellViewModel, isPlaying: Bool) {
        titleLabel.text = viewModel.title
        artistLabel.text = viewModel.artist
        if let artworkURL = viewModel.artworkURL {
            artworkImageView.loadImage(from: artworkURL, placeholder: UIImage(systemName: "music.note"))
        }
        
        updatePlayingIndicator(isPlaying: isPlaying)
    }
    
     func updatePlayingIndicator(isPlaying: Bool) {
        waveformView.isHidden = !isPlaying
        if isPlaying {
            startWaveformAnimation()
        } else {
            stopWaveformAnimation()
        }
    }
    
    private func createWaveformBars() {
        // Clear existing bars
        waveformView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add 5 bars with random heights (will be animated)
        for _ in 0..<5 {
            let bar = UIView()
            bar.backgroundColor = .systemGreen
            bar.layer.cornerRadius = 2
            waveformView.addArrangedSubview(bar)
            
            // Set initial height (will be animated)
            let heightConstraint = bar.heightAnchor.constraint(equalToConstant: 4)
            heightConstraint.isActive = true
        }
    }
    
    private func startWaveformAnimation() {
        // Animate each bar with a different timing to create wave effect
        for (index, bar) in waveformView.arrangedSubviews.enumerated() {
            let delay = Double(index) * 0.15
            
            UIView.animate(withDuration: 0.5, delay: delay, options: [.repeat, .autoreverse], animations: {
                bar.constraints.first?.constant = CGFloat.random(in: 4...20)
                bar.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    private func stopWaveformAnimation() {
        // Reset all animations and bar heights
        waveformView.arrangedSubviews.forEach { bar in
            bar.layer.removeAllAnimations()
            bar.constraints.first?.constant = 4
            bar.layoutIfNeeded()
        }
    }
}

