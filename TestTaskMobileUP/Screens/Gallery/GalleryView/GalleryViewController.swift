//
//  GalleryViewController.swift
//  TestTaskMobileUP
//
//  Created by Илья Андреев on 26.03.2022.
//

import UIKit
import Combine

// MARK: - Protocol GalleryViewControllerDelegate
/// Gallery ViewController delegate
protocol GalleryViewControllerDelegate: AnyObject {
    func signOutButtonTapped()
    func didSelectItemAt(_ index: Int)
}

// MARK: - Class GalleryViewController
/// Photo gallery screen
class GalleryViewController: LoadingViewController {
    
    // MARK: - Publishers
    /// Publisher that throws possible errors
    private(set) var error: PassthroughSubject<Error, Never> = .init()
    
    // MARK: - Public Properties
    ///  Delegate for external handling
    weak var delegate: GalleryViewControllerDelegate?
    
    // MARK: - Private Properties
    
    /// Main datasource
    private let viewModel: GalleryViewModable
    /// Collection view for photo showing
    private var collectionView: UICollectionView!
    /// Subscriptions storage
    private var bindings: Set<AnyCancellable> = .init()
    
    // MARK: - Initializers
    init(token: String) {
        viewModel = GalleryViewModel.init(token: token)
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
        
        configureCollectionView()
        configureViewController()
        configureNavigationItem()
        setupBindingsViewModelToView()
        showLoadingView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    // MARK: - Private Methods
    /// Primary collection view configuration
    private func configureCollectionView() {
        collectionView = .init(
            frame: view.bounds,
            collectionViewLayout: UIHelper.createTwoColumnFlowLayout(in: view)
        )
        collectionView.backgroundColor = .systemBackground
        collectionView.register(
            GalleryCollectionViewCell.self,
            forCellWithReuseIdentifier: GalleryCollectionViewCell.description()
        )
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    /// Primary dcreen and screentitle configutation
    private func configureViewController() {
        view.addSubViews(collectionView)
        title = "Mobile UP Gallery".localized()
    }
    
    /// Configurates navigation item and logout button
    private func configureNavigationItem() {
        navigationItem.backButtonTitle = ""
        
        let signOutButton = UIBarButtonItem()
        signOutButton.title = "Exit".localized()
        signOutButton.tintColor = .label
        signOutButton.action = #selector(signOutButtonTapped)
        signOutButton.target = self

        navigationItem.rightBarButtonItem = signOutButton
    }
    
    /// Initializes reactive connections
    private func setupBindingsViewModelToView() {
        viewModel.cellCount
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] count in
                self.collectionView.reloadData()
                // swiftlint:disable:next empty_count
                if count > 0 {
                    dismissLoadingView()
                }
            }
            .store(in: &bindings)
        
        viewModel.error
            .sink { [unowned self] error in
                self.error.send(error)
            }
            .store(in: &bindings)
    }
    
    @objc private func signOutButtonTapped() {
        delegate?.signOutButtonTapped()
    }
}

// MARK: - Extension UICollectionViewDataSource
extension GalleryViewController: UICollectionViewDataSource {
    
    /// Returns number of cells in current section of collection view
    /// - Parameters:
    ///   - collectionView: current collection view
    ///   - section: current section
    /// - Returns: count of cells
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.getCellCount()
    }
    
    /// Configurates propper cell for given position
    /// - Parameters:
    ///   - collectionView: current collection view
    ///   - indexPath: current position
    /// - Returns: properly configurated cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: GalleryCollectionViewCell.description(),
            for: indexPath) as! GalleryCollectionViewCell
        viewModel.getCell(for: indexPath.row, with: cell.id) { data, id in
            if cell.id == id {
                cell.set(by: data)
            }
        }
        return cell
    }
}

// MARK: - Extension UICollectionViewDelegate
extension GalleryViewController: UICollectionViewDelegate {
    
    /// Handles tap on the element of collection view
    /// - Parameters:
    ///   - collectionView: current collection view
    ///   - indexPath: tap position
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectItemAt(indexPath.row)
    }
}
