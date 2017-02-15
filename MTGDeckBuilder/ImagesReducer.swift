//
//  ImagesReducer.swift
//  Deckforger
//
//  Created by Gabriele Pregadio on 2/15/17.
//  Copyright © 2017 Gabriele Pregadio. All rights reserved.
//

import UIKit
import ReSwift

func createInitialImagesState() -> ImagesState {
    return ImagesState(mainImage: nil, currentMainImageRequestUrl: nil, isMainImageLoading: false, mainImageDownloadFailed: false, flipImage: nil, currentFlipImageRequestUrl: nil, isFlipImageLoading: false, flipImageDownloadFailed: false)
}

func imagesReducer(action: Action, state: ImagesState?) -> ImagesState {
    var state = state ?? createInitialImagesState()
    
    switch action {
        
    case let action as DownloadMainImage:
        state.mainImageDownloadFailed = false
        if action.isLoading {
            // Still in progress of downloading main image.
            state.mainImage = nil
            state.currentMainImageRequestUrl = action.imageUrl
            state.isMainImageLoading = true
        } else {
            // Main image download is complete.
            if state.currentMainImageRequestUrl == action.imageUrl {
                // The downloaded main image is the main image that was most recently requested.
                state.mainImage = action.imageResult
                state.currentMainImageRequestUrl = nil
                state.isMainImageLoading = false
            }
        }
        
    case let action as DownloadMainImageFailed:
        print("download main image failed")
        guard state.currentMainImageRequestUrl == action.imageUrl else { break }
        state.mainImage = nil
        state.currentMainImageRequestUrl = nil
        state.isMainImageLoading = false
        state.mainImageDownloadFailed = true
        
    case let action as DownloadFlipImage:
        state.flipImageDownloadFailed = false
        if action.isLoading {
            // Still in progress of downloading flip image.
            state.flipImage = nil
            state.currentFlipImageRequestUrl = action.imageUrl
            state.isFlipImageLoading = true
        } else {
            // Flip image download is complete.
            if state.currentFlipImageRequestUrl == action.imageUrl {
                // The downloaded flip image is the flip image that was most recently requested.
                state.flipImage = action.imageResult
                state.currentFlipImageRequestUrl = nil
                state.isFlipImageLoading = false
            }
        }
        
    case let action as DownloadFlipImageFailed:
        print("download flip image failed")
        guard state.currentFlipImageRequestUrl == action.imageUrl else { break }
        state.flipImage = nil
        state.currentFlipImageRequestUrl = nil
        state.isFlipImageLoading = false
        state.flipImageDownloadFailed = true
        
    default:
        break
        
    }
    
    return state
}
