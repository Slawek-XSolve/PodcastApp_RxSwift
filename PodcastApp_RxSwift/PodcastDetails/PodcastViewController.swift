//
//  PodcastViewController.swift
//  PodcastApp_SwiftMVC
//
//  Created by Slawomir Zagorski on 23.11.2016.
//  Copyright © 2016 SZ. All rights reserved.
//

import UIKit

class PodcastViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!

    fileprivate var podcast: PodcastModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let podcast = podcast {
            configure(withPodcast: podcast)

            self.podcast = nil
        }
    }

    func configure(withPodcast podcast: PodcastModel) {
        guard isViewLoaded else {
            self.podcast = podcast

            return
        }
        navigationItem.title = podcast.trackName
        lblTitle.text = podcast.trackName
        lblSubtitle.text = podcast.artistName
        lblDescription.text = podcast.collectionName
        
        if let artworkURL = podcast.artworkURL {
            imageView.sd_setImage(with: artworkURL)
        }
    }

}
