//
// Created by Krupin Maxim
// Copyright (c) 2017 Maxim. All rights reserved.
//

import Foundation
import ReSwift
import AELog


class AppStoreHolder {

    /**
     * The Store stores your entire app state in the form of a single data structure.
     * This state can only be modified by dispatching Actions to the store.
     * Whenever the state in the store changes, the store will notify all observers.
     */
    public static let store = Store<AppState>(reducer: AppReducer().mainReducer, state: AppState.init(), middleware: [loggingMiddleware]);

    /**
    * ReSwift supports middleware in the same way as Redux does.
    * The simplest example of a middleware, is one that prints all actions to the console.
    */
    public static let loggingMiddleware: Middleware<Any> = { dispatch, getState in
        return { next in
            return { action in
                aelog("<action> \(action)");
                return next(action);
            }
        }

    }
}

