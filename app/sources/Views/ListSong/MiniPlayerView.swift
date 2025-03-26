//
//  PlayView.swift
//  MusicPlayer_Nusatech
//
//  Created by Aries Prasetyo on 26/03/25.
//


import UIKit

protocol MiniPlayerViewDelegate: AnyObject {
    func didTapPlay()
    func didTapStop()
    func didNextSong()
    func didPrevSong()
}

final class MiniPlayerView: UIView {
    
    private lazy var titleLabel: UILabel = {
        let label: UILabel = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Not Playing"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 16)
        
        return label
    }()
    
    
    private lazy var playButton: UIButton = {
        let button: UIButton = UIButton(type: .system)
        
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var stopButton: UIButton = {
        let button: UIButton = UIButton(type: .system)
        
        button.setImage(UIImage(systemName: "stop.fill"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(stopTapped), for: .touchUpInside)
        button.isHidden = true
        
        return button
    }()
    
    private lazy var nextButton: UIButton = {
        let button: UIButton = UIButton(type: .system)
        button.setImage(UIImage(systemName: "forward.fill"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var previousButton: UIButton = {
        let button: UIButton = UIButton(type: .system)
        
        button.setImage(UIImage(systemName: "backward.fill"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(prevTapped), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var progressView : UIProgressView = {
        let progres: UIProgressView =  UIProgressView(progressViewStyle: .bar)
        
        progres.progressTintColor = .systemBlue
        progres.trackTintColor = .lightGray
        progres.layer.cornerRadius = 4
        progres.clipsToBounds = true
        progres.progress = 0
        
        return progres
    }()
    
    private lazy var buttonStack: UIStackView = {
        let stackView: UIStackView = UIStackView(arrangedSubviews: [previousButton, playButton, nextButton])
        
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, progressView, buttonStack])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
  

    weak var delegate: MiniPlayerViewDelegate?
    
    private var isPlaying = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        clipsToBounds = false


        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 36),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -36),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])

        
        alpha = 0
    }

    @objc private func playTapped() {
        isPlaying.toggle()
        updatePlayingStatus(isPlaying: isPlaying)
        delegate?.didTapPlay()
    }
    
    @objc private func nextTapped() {
        delegate?.didNextSong()
    }
    
    @objc private func prevTapped() {
        delegate?.didPrevSong()
    }
    
    @objc private func stopTapped() {
        isPlaying = false
        updatePlayingStatus(isPlaying: false)
        delegate?.didTapStop()
    }
    
    func updateSong(title: String) {
        isPlaying = true
        titleLabel.text = title
        showMiniPlayer()
    }

    func updatePlayingStatus(isPlaying: Bool) {
        let iconName = isPlaying ? "pause.fill" : "play.fill"
        playButton.setImage(UIImage(systemName: iconName), for: .normal)
        if !isPlaying { progressView.progress = 0 }
    }

    func updateProgress(_ progress: Float) {
        progressView.setProgress(progress, animated: true)
    }

    private func showMiniPlayer() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        }
    }

    func hideMiniPlayer() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0
        }
    }
}

