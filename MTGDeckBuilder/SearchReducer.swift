//
//  SearchReducer.swift
//  Deckforger
//
//  Created by Gabriele Pregadio on 2/6/17.
//  Copyright © 2017 Gabriele Pregadio. All rights reserved.
//

import Foundation
import ReSwift

func createInitialSearchState() -> SearchState {
    return SearchState(cardResults: nil, additionalCardResults: nil, parameters: nil, shouldSearch: false, isLoading: false, currentRequestPage: 1)
}

func searchReducer(action: Action, state: SearchState?) -> SearchState {
    var state = state ?? createInitialSearchState()
    
    switch action {
        
    case let action as ReceivedMemoryWarning:
        switch action.restorationIdentifier {
        case StoryboardIdentifiers.addCard.rawValue, StoryboardIdentifiers.filters.rawValue:
            state.additionalCardResults = nil
        case StoryboardIdentifiers.cardDetail.rawValue:
            state.parameters = nil
            state.cardResults = nil
        default:
            state.parameters = nil
            state.cardResults = nil
            state.additionalCardResults = nil
        }
        
    case let action as SearchForCards:
        state.cardResults = action.result
        state.parameters = action.parameters
        state.shouldSearch = false
        state.isLoading = action.isLoading
        state.currentRequestPage = action.currentPage
        
    case let action as SearchForAdditionalCards:
        state.additionalCardResults = action.result
        state.isLoading = action.isLoading
        
    case let action as PrepareForSearch:
        state.parameters = action.parameters
        state.shouldSearch = true
        
    default:
        break
    }
    
    return state
}
