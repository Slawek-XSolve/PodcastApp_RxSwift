//
//  PodcastDataSource.swift
//  PodcastApp_SwiftMVC
//
//  Created by Slawomir Zagorski on 23.11.2016.
//  Copyright © 2016 SZ. All rights reserved.
//

import Foundation
import RxSwift

class PodcastDataSource {
    let podcasts: Variable<[PodcastModel]> = Variable([])
    let working: Variable<Bool> = Variable(false)
    let searchTerm: Variable<String> = Variable("")

    fileprivate let itunesAPI: String = "https://itunes.apple.com/search"
    fileprivate let itemLimit: Int = 50
    
    fileprivate let disposeBag = DisposeBag()
    fileprivate var currentSearchTerm: String = ""
    fileprivate var currentRequestDisposable: Disposable?

    init() {
        searchTerm
            .asObservable()
            .distinctUntilChanged(==)
            .subscribe(onNext: { [weak self] (_) in
                self?.reloadPodcasts()
            })
            .addDisposableTo(disposeBag)
    }

    subscript(index: Int) -> PodcastModel {
        get {
            return podcasts.value[index]
        }
    }

}

extension PodcastDataSource {

    fileprivate var urlSession: URLSession {
        return URLSession.shared
    }

    fileprivate func apiURL(searchTerm: String) -> URL {
        let encodedSearchTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

        return URL(string: "\(itunesAPI)?limit=\(itemLimit)&term=\(encodedSearchTerm)")!
    }

    fileprivate func reloadPodcasts() {
        if let requestDisposable = currentRequestDisposable {
            requestDisposable.dispose()
            currentRequestDisposable = nil
        }
        guard !searchTerm.value.isEmpty else {
            podcasts.value = []
            currentSearchTerm = ""
            working.value = false

            return
        }
        let searchedTerm = searchTerm.value

        currentRequestDisposable = urlSession.rx.data(request: URLRequest(url: apiURL(searchTerm: searchTerm.value))).subscribe(onNext: { [weak self] (data) in
            self?.handleRequestSuccess(data, searchedTerm: searchedTerm)
        }, onError: { [weak self] (error) in
            self?.handleRequestError(error)
        })
        working.value = true
    }

    fileprivate func handleRequestSuccess(_ data: Data, searchedTerm: String) {
        guard let responseModel = APIResponeModel(data: data) else {
            self.podcasts.value = []
            self.currentSearchTerm = ""
            self.working.value = false

            return
        }
        self.podcasts.value = responseModel.results
        self.currentSearchTerm = searchedTerm
        self.working.value = false
    }

    fileprivate func handleRequestError(_ error: Error) {
        guard (error as NSError).code == NSURLErrorCancelled else {
            return
        }
        self.podcasts.value = []
        self.currentSearchTerm = ""
        self.working.value = false
    }

}
