//
// Created by Krupin Maxim
// Copyright (c) 2017 Maxim. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer
import AELog
import ReSwift

/**
 * Simple wrapper for AVAudioPlayer. It implements play/resume/stop/pause methods for controls of audio.
 * It can change volume.
 */
class AppAudioPlayer: NSObject, AVAudioPlayerDelegate {

    fileprivate var avPlayer: AVAudioPlayer?;
    fileprivate var audioSession: AVAudioSession = AVAudioSession.sharedInstance();

    fileprivate var innerState: AppState? = nil;

    override init() {
        super.init();
        self.setAudioSession();
    }

    fileprivate func setAudioSession() {
        do {
            try self.audioSession.setCategory(AVAudioSessionCategoryPlayback);
        } catch {
            aelog("Error in set category: \(error)");
        }
        do {
            try self.audioSession.setActive(true);
        } catch {
            aelog("Error in set active: \(error)");
        }
    }

    func play(_ song: AnyObject?) {
        self.stop();
        if let song = song, let url: URL = song.value(forProperty: MPMediaItemPropertyAssetURL) as? URL {
            self.avPlayer = try? AVAudioPlayer(contentsOf: url);
            self.avPlayer?.delegate = self;
            self.avPlayer?.play();
            if let volume = self.innerState?.currentVolume {
                self.setVolume(volume);
            }
        } else {
            aelog("Cannot play");
        }
    }

    func resumeOrPlay(_ song: AnyObject?) {
        if let player = self.avPlayer {
            player.play();
        } else {
            play(song);
        }
    }

    func stop() {
        self.avPlayer?.stop();
        self.avPlayer = nil;
    }

    func pause() {
        self.avPlayer?.pause();
    }

    func setVolume(_ value: Float) {
        self.avPlayer?.volume = value;
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        AppStoreHolder.store.dispatch(.PlayerDidFinishPlaying);
    }

}

/**
 * Handles states of app
 */
extension AppAudioPlayer: ReSwift.StoreSubscriber {

    func newState(state: AppState) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            let oldState = self?.innerState;
            self?.innerState = state;

            if differ(oldState?.isPlayingMode, state.isPlayingMode) { // Play/pause
                if state.isPlayingMode { // Want to play
                    let isSongChanged: Bool = differ(oldState?.currentSongIndex, state.currentSongIndex);
                    if isSongChanged {
                        // Play new song
                        self?.play(state.getCurrentMediaItem());
                    } else {
                        // Resume old song, or it can be nil, so play new
                        self?.resumeOrPlay(state.getCurrentMediaItem());
                    }
                } else {
                    self?.pause();
                }
            } else if differ(oldState?.currentSongIndex, state.currentSongIndex) { // Change song
                if state.isPlayingMode {
                    // Play new song
                    self?.play(state.getCurrentMediaItem());
                } else {
                    // Reset song
                    self?.stop();
                }
            }

            // Change volume
            if differ(oldState?.currentVolume, state.currentVolume) {
                self?.setVolume(state.currentVolume);
            }
        }
    }

}
