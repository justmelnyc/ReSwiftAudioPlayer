//
// Created by Krupin Maxim on 11/09/2017.
// Copyright (c) 2017 Maxim. All rights reserved.
//

import Foundation
import ReSwift

/**
* Aliases for using actions
*/
extension Store {

    func dispatch(_ action: AppAction) {
        self.dispatch(action as Action);
    }

    func dispatch(_ action: PlaylistsAction) {
        self.dispatch(action as Action);
    }

    func dispatch(_ action : SongsAction) {
        self.dispatch(action as Action);
    }

    func dispatch(_ action : PlayerAction) {
        self.dispatch(action as Action);
    }

}