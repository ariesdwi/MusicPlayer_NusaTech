//
//  LauncScreen.swift
//  InstagramCloning_Uikit
//
//  Created by Aries Prasetyo on 05/03/25.
//

import UIKit

class LaunchScreenViewController: UIViewController {
    
    let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "tinderLogo"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLogo()
        animateLogo()
    }
    
    private func setupLogo() {
        view.addSubview(logoImageView)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 100),
            logoImageView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }

    private func animateLogo() {
        UIView.animate(withDuration: 1.5,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.8,
                       options: .curveEaseInOut,
                       animations: {
            self.logoImageView.transform = CGAffineTransform(scaleX: 3.0, y: 3.0)
            self.logoImageView.alpha = 0
        }, completion: { _ in
            self.navigateToMainApp()
        })
    }

    private func navigateToMainApp() {
        let mainVC = SongViewController()
        mainVC.modalTransitionStyle = .crossDissolve
        mainVC.modalPresentationStyle = .fullScreen
        self.present(mainVC, animated: true)
    }
}
