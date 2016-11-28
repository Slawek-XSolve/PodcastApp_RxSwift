//
//  PodcastModel.swift
//  PodcastApp_SwiftMVC
//
//  Created by Slawomir Zagorski on 23.11.2016.
//  Copyright © 2016 SZ. All rights reserved.
//

import SwiftyJSON

struct PodcastModel {

    let artistName: String
    let collectionName: String?
    let trackName: String?
    fileprivate let artworkUrl60: String?
    fileprivate let artworkUrl100: String?
    var artworkURL: URL? {
        guard let artworkUrl = (artworkUrl100 != nil) ? artworkUrl100 : artworkUrl60 else {
            return nil
        }
        return URL(string: artworkUrl)
    }

    init?(_ json: JSON) {
        guard let artistName = json["artistName"].string else {
            return nil
        }
        self.artistName = artistName
        collectionName = json["collectionName"].string
        trackName = json["trackName"].string
        artworkUrl60 = json["artworkUrl60"].string
        artworkUrl100 = json["artworkUrl100"].string
    }
    
}

extension PodcastModel {

    fileprivate static func models(_ fieldsArray: [JSON]) -> [PodcastModel] {
        return fieldsArray.map { PodcastModel($0)! }
    }

    static func models(data: Data) -> [PodcastModel] {
        guard let jsonArray = JSON(data: data).array else {
            return []
        }
        return self.models(jsonArray)
    }

}

struct APIResponeModel {

    let resultCount: Int
    let results: Array<PodcastModel>

    init?(_ json: [String : JSON]) {
        guard let resultCount = json["resultCount"]?.int, let results = json["results"]?.array else {
            return nil
        }
        self.resultCount = resultCount
        self.results = PodcastModel.models(results)
    }

    init?(data: Data) {
        guard let json = JSON(data: data).dictionary else {
            return nil
        }
        self.init(json)
    }

}
