//
//  Fetch Images ACs.swift
//  Deckforger
//
//  Created by Gabriele Pregadio on 2/15/17.
//  Copyright © 2017 Gabriele Pregadio. All rights reserved.
//

import Foundation
import ReSwift
import Alamofire
import ObjectMapper

func fetchMainImageActionCreator(url: URL) -> Store<RootState>.ActionCreator {
    return { state, store in
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    if let image = UIImage(data: data) {
                        store.dispatch(DownloadMainImage(imageUrl: url, imageResult: image, isLoading: false))
                    } else {
                        store.dispatch(DownloadMainImageFailed(imageUrl: url))
                    }
                }
            } else {
                DispatchQueue.main.async {
                    store.dispatch(DownloadMainImageFailed(imageUrl: url))
                }
            }
        }
        return DownloadMainImage(imageUrl: url, imageResult: nil, isLoading: true)
        
    }
}

func fetchFlipImageActionCreator(url: URL) -> Store<RootState>.ActionCreator {
    return { state, store in
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    if let image = UIImage(data: data) {
                        store.dispatch(DownloadFlipImage(imageUrl: url, imageResult: image, isLoading: false))
                    } else {
                        store.dispatch(DownloadFlipImageFailed(imageUrl: url))
                    }
                }
            } else {
                DispatchQueue.main.async {
                    store.dispatch(DownloadMainImageFailed(imageUrl: url))
                }
            }
        }
        return DownloadFlipImage(imageUrl: url, imageResult: nil, isLoading: true)
    
    }
}
