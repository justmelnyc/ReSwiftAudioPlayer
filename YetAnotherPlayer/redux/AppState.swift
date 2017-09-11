//
// Created by Krupin Maxim
// Copyright (c) 2017 Maxim. All rights reserved.
//

import Foundation
import ReSwift
import MediaPlayer

/**
 * The state struct store entire application state, that includes the UI state and the state of model layer.
 */
struct AppState: StateType {

    var playlists: [PlaylistData] = []; // We see it in playlists view

    var currentPlaylistIndex: Int? = nil;
    var currentPlayist: [MPMediaItem] = []; // We see it in songs view
    var currentSongIndex: Int? = nil;

    var isPlayingMode: Bool = false;

    var isMediaPickerMode: Bool = false;
    var currentVolume: Float = 1.0;

}

extension AppState {

    func getCurrentMediaItem() -> MPMediaItem? {
        return currentSongIndex.flatMap { (index) -> MPMediaItem? in
            if index < currentPlayist.count {
                return currentPlayist[index];
            }
            return nil;
        }
    }

    func getPreferencesData() -> PreferencesData {
        return PreferencesData.init(playlists: self.playlists, volume: self.currentVolume);
    }

}
