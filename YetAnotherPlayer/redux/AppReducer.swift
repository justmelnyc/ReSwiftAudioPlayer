//
// Created by Krupin Maxim
// Copyright (c) 2017 Maxim. All rights reserved.
//

import Foundation
import ReSwift
import MediaPlayer
import AELog


/**
 * Reducers provide pure functions, that based on the current action and the current app state, create a new app state
 */
class AppReducer {

    /**
    * Top level reducer. It routes actions in sub-reducers
    */
    public func mainReducer(action: Action, state: AppState?) -> AppState {
        let state = state ?? AppState();

        // Handle AppAction
        if let action = action as? AppAction {
            return handle(appAction: action, inState: state);
        }

        // Handle PlaylistsAction
        if let action = action as? PlaylistsAction {
            return handle(playlistsAction: action, inState: state);
        }

        // Handle SongsAction
        if let action = action as? SongsAction {
            return handle(songsAction: action, inState: state);
        }

        // Handle PlayerAction
        if let action = action as? PlayerAction {
            return handle(playerAction: action, inState: state);
        }

        aelog("Unknown action: \(action)");
        return state;
    }
    
    // ------------- All about AppAction

    fileprivate func handle(appAction: AppAction, inState: AppState) -> AppState {
        var state = inState;
        switch appAction {
        case .RestorePreferences:
            // Read preferences and set playlist and volume
            DispatchQueue.global(qos: .userInteractive).sync {
                if let savedData = readPreferences() {
                    state.playlists = savedData.playlists;
                    state.currentVolume = savedData.volume;
                }
            }
        case .MediaPickerMode(let isOn):
            state.isMediaPickerMode = isOn;
        }
        return state;
    }
    
    // ------------- All about PlaylistsAction

    fileprivate func handle(playlistsAction: PlaylistsAction, inState: AppState) -> AppState {
        var state = inState;
        switch playlistsAction {
        case .AddPlaylist(let name):
            // Add new playlist and set its songs by empty
            state.playlists.append(PlaylistData.init(name: name, songs: []));
            state.currentPlaylistIndex = state.playlists.count - 1;
            state.currentPlayist = [];
            savePreferences(savedData: state.getPreferencesData());

        case .RemovePlaylist(let index):
            if index < state.playlists.count {
                state.playlists.remove(at: index);
                // If it current playlist, reset state
                if let currentPlaylistIndex = state.currentPlaylistIndex, currentPlaylistIndex == index {
                    state.currentPlaylistIndex = nil;
                    state.currentPlayist = [];
                    state.currentSongIndex = nil;
                    state.isPlayingMode = false;
                }
            }
            savePreferences(savedData: state.getPreferencesData());

        case .SelectPlaylist(let index):
            // Reset current state
            state.currentSongIndex = nil;
            state.isPlayingMode = false;
            if index < state.playlists.count {
                state.currentPlaylistIndex = index;
                // Fill media items for playlist
                DispatchQueue.global(qos: .userInteractive).sync {
                    state.currentPlayist = state.playlists[index].songs.flatMap {
                        getMediaItemFromPid($0);
                    }
                }
            } else {
                // Handler for wrong action
                state.currentPlaylistIndex = nil;
            }
        }
        return state;
    }

    // ------------- All about SongsAction
    
    fileprivate func handle(songsAction: SongsAction, inState: AppState) -> AppState {
        var state = inState;
        switch songsAction {
        case .AddMediaItems(let items):
            state.currentPlayist += items;
            // Fill playlist model with new songs ids
            if let playlistIndex = state.currentPlaylistIndex, playlistIndex < state.playlists.count {
                state.playlists[playlistIndex].songs += items.map {
                    $0.persistentID
                };
            }
            savePreferences(savedData: state.getPreferencesData());

        case .RemoveMediaItem(let songIndex):
            if songIndex < state.currentPlayist.count {
                state.currentPlayist.remove(at: songIndex);
                // Change playlist model
                if let playlistIndex = state.currentPlaylistIndex, playlistIndex < state.playlists.count {
                    state.playlists[playlistIndex].songs.remove(at: songIndex);
                }
                // Change index for current song, because it has offset
                if let currentSongIndex = state.currentSongIndex, currentSongIndex > songIndex {
                    state.currentSongIndex = (state.currentSongIndex! - 1) % state.currentPlayist.count;
                }
            }
            savePreferences(savedData: state.getPreferencesData());

        case .SelectSong(let index):
            if index < state.currentPlayist.count {
                state.isPlayingMode = true;
                state.currentSongIndex = index;
            } else {
                // Handler for wrong action
                state.isPlayingMode = false;
                state.currentSongIndex = nil;
            }
        }
        return state;
    }

    // ------------- All about PlayerAction
    
    fileprivate func handle(playerAction: PlayerAction, inState: AppState) -> AppState {
        var state = inState;
        switch playerAction {

        case .PlayerDidFinishPlaying, .NextSong:
            // Turn next song if model is valid
            if state.currentPlayist.count > 0, state.currentSongIndex != nil {
                state.currentSongIndex = (state.currentSongIndex! + 1) % state.currentPlayist.count;
            } else {
                state.currentSongIndex = nil;
            }

        case .ChangeVolume(let value):
            state.currentVolume = value;
            savePreferences(savedData: state.getPreferencesData());

        case .TogglePlayPause:
            state.isPlayingMode = !state.isPlayingMode;
            if state.currentSongIndex == nil, state.currentPlayist.count > 0 {
                state.currentSongIndex = 0;
            }

        case .PrevSong:
            // Turn prev song if model is valid
            if state.currentPlayist.count > 0, state.currentSongIndex != nil {
                state.currentSongIndex = (state.currentSongIndex! + state.currentPlayist.count - 1) % state.currentPlayist.count;
            } else {
                state.currentSongIndex = nil;
            }

        }
        return state;
    }

    // ------------- Preferences
    
    fileprivate func savePreferences(savedData: PreferencesData) {
        DispatchQueue.global(qos: .userInteractive).async {
            let success = NSKeyedArchiver.archiveRootObject(savedData, toFile: self.getFileName());
            aelog("Saved success: \(success)");
        }
    }

    fileprivate func readPreferences() -> PreferencesData? {
        let read = NSKeyedUnarchiver.unarchiveObject(withFile: getFileName());
        return read as? PreferencesData;
    }

    fileprivate func getFileName() -> String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/preferences";
    }

    // ------------- Media
    
    fileprivate func getMediaItemFromPid(_ pid: MPMediaEntityPersistentID) -> MPMediaItem? {
        let pred = MPMediaPropertyPredicate(value: pid, forProperty: MPMediaEntityPropertyPersistentID);
        let query = MPMediaQuery();
        query.addFilterPredicate(pred);
        if let items = query.items, items.count > 0 {
            return items[0];
        } else {
            return nil;
        }
    }

}


