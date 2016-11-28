//
//  PodcastListViewController.swift
//  PodcastApp_SwiftMVC
//
//  Created by Slawomir Zagorski on 22.11.2016.
//  Copyright © 2016 SZ. All rights reserved.
//

import UIKit
import SDWebImage
import RxSwift
import RxCocoa

class PodcastListViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    fileprivate var dataSource: PodcastDataSource!

    fileprivate let reuseIdentifier = "PodcastCell"
    fileprivate let podcastDetailSegueName = "PodcastDetailSegue"

    fileprivate let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = PodcastDataSource()

        subscribeToDataSourceAcitivity()
        subscribeToDataSourceChange()
        subscribeToSearchTermChange()

        bindCollectionViewCellToDataSource()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == podcastDetailSegueName, let indexPath = collectionView?.indexPath(for: sender as! PodcastCollectionViewCell) else {
            return
        }
        (segue.destination as! PodcastViewController).configure(withPodcast: dataSource[indexPath.row])
    }

}

extension PodcastListViewController {

    fileprivate func subscribeToDataSourceAcitivity() {
        dataSource.working
            .asObservable()
            .distinctUntilChanged(==)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (isWorking) in
                if (isWorking) {
                    self.activityIndicator.startAnimating()
                } else {
                    self.activityIndicator.stopAnimating()
                }
                })
            .addDisposableTo(disposeBag)
    }

    fileprivate func subscribeToDataSourceChange() {
        dataSource.podcasts
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (_) in
                self.collectionView.reloadData()
                })
            .addDisposableTo(disposeBag)
    }

    fileprivate func subscribeToSearchTermChange() {
        searchBar.rx.text
            .debounce(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged(==)
            .subscribe(onNext: { [unowned self] (searchTerm) in
                self.dataSource!.searchTerm.value = searchTerm!
                })
            .addDisposableTo(disposeBag)
    }

}

extension PodcastListViewController {

    fileprivate func bindCollectionViewCellToDataSource() {
        dataSource.podcasts
            .asObservable()
            .observeOn(MainScheduler.instance)
            .bindTo(collectionView.rx.items(cellIdentifier: reuseIdentifier, cellType: PodcastCollectionViewCell.self)) { _, podcast, cell in
                if let imageURL = podcast.artworkURL {
                    cell.imageView.sd_setImage(with: imageURL)
                } else {
                    cell.imageView.image = nil
                }
                cell.label.text = podcast.trackName
            }
            .addDisposableTo(disposeBag)
    }

}
