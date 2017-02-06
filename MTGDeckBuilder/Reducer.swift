//
//  Reducer.swift
//  MTGPrices
//
//  Created by Gabriele Pregadio on 11/28/16.
//  Copyright © 2016 Gabriele Pregadio. All rights reserved.
//

import Foundation
import ReSwift
import CoreData

struct StateReducer: Reducer {
    func handleAction(action: Action, state: RootState?) -> RootState {
        // Delegate to sub-reducers.
        return RootState(
            coreDataState: coreDataReducer(action: action, state: state?.coreDataState),
            searchState: searchReducer(action: action, state: state?.searchState)
        )
    }
}
