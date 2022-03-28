//
//  GalleryViewController.swift
//  TestTaskMobileUP
//
//  Created by Илья Андреев on 26.03.2022.
//

import UIKit

class GalleryViewController: UIViewController {
    
    enum Section: Hashable { case main }
    
    private var photos: [Photo] = []
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Photo>!
    
    private let token: String
    private let signOut: (() -> Void)
    private let choosen: (Int) -> Void
    
    init(
        token: String,
        signOut: @escaping () -> Void,
        choosen: @escaping (Int) -> Void
    ) {
        self.token = token
        self.signOut = signOut
        self.choosen = choosen
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureViewController()
        configureDataSource()
        configureNavigationItem()
        DispatchQueue.global().async {
            self.fetchFotos(token: self.token)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    @objc private func signOutButtonTapped() {
        signOut()
    }
    
    private func configureViewController() {
        view.addSubViews(collectionView)
        title = "Mobile UP Gallery"
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(
            frame: view.bounds,
            collectionViewLayout: UIHelper.createTwoColumnFlowLayout(
                in: view
            )
        )
        collectionView.backgroundColor = .systemBackground
        collectionView.register(
            GalleryCollectionViewCell.self,
            forCellWithReuseIdentifier: GalleryCollectionViewCell.description()
        )
        collectionView.delegate = self
    }
    
    private func configureNavigationItem() {
        navigationItem.backButtonTitle = ""
        
        let signOutButton = UIBarButtonItem()
        signOutButton.title = "Выход"
        signOutButton.tintColor = .label
        signOutButton.action = #selector(signOutButtonTapped)
        signOutButton.target = self

        navigationItem.rightBarButtonItem = signOutButton
    }
    
    private func fetchFotos(token: String) {
        guard let url = VKClient.photosURL(with: token) else { return }
        NetworkingManager.shared.fetchData(from: url) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                do {
                    let result = try JSONDecoder().decode(VKResponse.self, from: data)
                    self.photos = result.album.photos
                    DispatchQueue.main.sync {
                        self.updateData(on: self.photos)
                    }
                } catch {
                    print(error)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Photo>(
            collectionView: collectionView
        ) { collectionView, indexPath, photo in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: GalleryCollectionViewCell.description(),
                for: indexPath) as! GalleryCollectionViewCell
            cell.set(by: photo)
            return cell
        }
    }
    
    private func updateData(on photos: [Photo]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Photo>()
        snapshot.appendSections([.main])
        snapshot.appendItems(photos)
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
}
    
extension GalleryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        choosen(indexPath.row)
    }
}
