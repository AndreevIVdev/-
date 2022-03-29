//
//  AuthViewController.swift
//  MobileUPTestTask
//
//  Created by Илья Андреев on 25.03.2022.
//

import UIKit

// MARK: - Protocol AuthViewControllerDelegate
protocol AuthViewControllerDelegate: AnyObject {
    func signInButtonTapped()
}

// MARK: - Class AuthViewController
class AuthViewController: UIViewController {
    
    // MARK: - Public Properties
    weak var delegate: AuthViewControllerDelegate?
    
    // MARK: - Private Properties
    private let titleLabel: UILabel = .init()
    private let actionButton: UIButton = .init()
    
    // MARK: - Initializers
    init() {
        super.init(nibName: nil, bundle: nil)
        print("\(String(describing: type(of: self))) INIT")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Deinitializers
    deinit {
        print("\(String(describing: type(of: self))) DEINIT")
    }
    
    // MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        configureTitleLabel()
        configureActionButton()
    }
    
    // MARK: - Private Methods
    private func configureViewController() {
        view.backgroundColor = .systemGray5
        view.addSubViews(
            titleLabel,
            actionButton
        )
    }
    
    private func configureTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .preferredFont(forTextStyle: .largeTitle).bold()
        titleLabel.text = "Mobile Up\nGallery".localized()
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 2
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Design.padding),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Design.padding),
            titleLabel.topAnchor.constraint(
                equalTo: view.topAnchor,
                constant: view.frame.height / 5
            )
        ])
    }
    
    private func configureActionButton() {
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.setTitle("Вход через VK", for: .normal)
        actionButton.backgroundColor = .black
        actionButton.titleLabel?.textColor = .white
        actionButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        actionButton.layer.cornerRadius = Design.cornerRadius
        
        NSLayoutConstraint.activate([
            actionButton.heightAnchor.constraint(equalToConstant: Design.buttonHeight),
            actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Design.padding),
            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Design.padding),
            actionButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Design.bottomPadding)
        ])
        
        actionButton.addTarget(
            self,
            action: #selector(actionButtonTapped),
            for: .touchUpInside
        )
    }
    
    @objc private  func actionButtonTapped() {
        delegate?.signInButtonTapped()
    }
}
