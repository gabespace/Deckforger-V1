//
//  Images Actions.swift
//  Deckforger
//
//  Created by Gabriele Pregadio on 2/15/17.
//  Copyright © 2017 Gabriele Pregadio. All rights reserved.
//

import UIKit
import ReSwift
import Alamofire

struct DownloadMainImage: Action {
    let imageUrl: URL
    let imageResult: UIImage?
    let isLoading: Bool
}

struct DownloadMainImageFailed: Action {
    let imageUrl: URL
}

struct DownloadFlipImage: Action {
    let imageUrl: URL
    let imageResult: UIImage?
    let isLoading: Bool
}

struct DownloadFlipImageFailed: Action {
    let imageUrl: URL
}
