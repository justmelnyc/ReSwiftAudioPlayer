//
// Created by Krupin Maxim
// Copyright (c) 2017 Maxim. All rights reserved.
//

import Foundation
import ReSwift
import MediaPlayer

// Actions are a declarative way of describing a state change. 
// Actions don’t contain any code, they are consumed by the store and forwarded to reducers.
// Reducers will handle the actions by implementing a different state change for each action.

/**
 * Actions for app in general. Now app is simple, so we have just one action.
 */
enum AppAction: Action {
    case RestorePreferences;
    case MediaPickerMode(isOn: Bool);
}

/**
 * Actions for working with playlists, just add/remove/select
 */
enum PlaylistsAction: Action {
    case AddPlaylist(name: String);
    case RemovePlaylist(index: Int);
    case SelectPlaylist(index: Int);
}

/**
 * Actions for working with songs, add/remove/select
 */
enum SongsAction : Action {
    case AddMediaItems(items: Set<MPMediaItem>);
    case RemoveMediaItem(index: Int);
    case SelectSong(index: Int);
}

/**
 * Actions for working with player, play/pause/prev/next/volume and trigger by end
 */
enum PlayerAction : Action {
    case TogglePlayPause;
    case PrevSong;
    case NextSong;
    case ChangeVolume(value: Float);
    case PlayerDidFinishPlaying;
}
