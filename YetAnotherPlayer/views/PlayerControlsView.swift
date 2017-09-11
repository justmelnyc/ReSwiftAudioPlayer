//
// Created by Maxim on 06/09/17.
// Copyright (c) 2017 Maxim. All rights reserved.
//

import Foundation
import UIKit
import AELog
import ReSwift

/**
 * Controller for PlayerControls.xib
 * Works with play/pause/prev/next buttons and volume slider
 */
class PlayerControlsView: UIView {

    fileprivate static let PLAY_PAUSE_BTN_POS: Int = 2;

    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var prevSongBtn: UIBarButtonItem!
    @IBOutlet weak var nextSongBtn: UIBarButtonItem!
    @IBOutlet weak var volumeSlider: UISlider!

    var playButton: UIBarButtonItem!;
    var pauseButton: UIBarButtonItem!;

    fileprivate var innerState: AppState? = nil;

    class func instanceFromNib() -> PlayerControlsView {
        return UINib(nibName: "PlayerControls", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! PlayerControlsView;
    }

    public func setEnabled(isAllEnabled: Bool) {
        for btn in [prevSongBtn, playButton, pauseButton, nextSongBtn] {
            btn?.isEnabled = isAllEnabled;
        }
    }

    override func awakeFromNib() {
        self.playButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.play, target: self, action: #selector(PlayerControlsView.handlePlayPauseBtnTap(_:)));
        self.pauseButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.pause, target: self, action: #selector(PlayerControlsView.handlePlayPauseBtnTap(_:)));

        setPlayPauseButton(isPlaying: false);
        setEnabled(isAllEnabled: false);
    }

    func handlePlayPauseBtnTap(_ sender: AnyObject) {
        AppStoreHolder.store.dispatch(.TogglePlayPause);
    }

    @IBAction func handlePrevBtnTap(_ sender: UIBarButtonItem) {
        AppStoreHolder.store.dispatch(.PrevSong);
    }

    @IBAction func handleNextBtnTap(_ sender: UIBarButtonItem) {
        AppStoreHolder.store.dispatch(.NextSong);
    }


    @IBAction func handleVolumeValueChanged(_ sender: UISlider) {
        AppStoreHolder.store.dispatch(.ChangeVolume(value: sender.value));
    }

    func setPlayPauseButton(isPlaying: Bool) {
        self.toolbar.items![PlayerControlsView.PLAY_PAUSE_BTN_POS] = isPlaying ? pauseButton : playButton;
    }

    /**
    * Beatiful animation for hidden state (just move down)
    */
    func setHidden(isHidden: Bool) {
        if (isHidden) {
            let transformDelta = self.bounds.height;
            UIView.animate(withDuration: 0.1, animations: { [weak self] _ in
                self?.transform = CGAffineTransform(translationX: 0, y: transformDelta);
            }, completion: { [weak self] _ in
                self?.isHidden = true;
            });
        } else {
            self.isHidden = false;
            UIView.animate(withDuration: 0.1, animations: { [weak self] _ in
                self?.transform = CGAffineTransform(translationX: 0, y: 0);
            });
        }

    }

}

// -------------------------- All about state

extension PlayerControlsView: ReSwift.StoreSubscriber {

    func newState(state: AppState) {
        DispatchQueue.main.async { [weak self] in
            let oldState = self?.innerState;
            self?.innerState = state;

            if differ(oldState?.isMediaPickerMode, state.isMediaPickerMode) { // Hide self when media picker mode
                self?.setHidden(isHidden: state.isMediaPickerMode);
            }

            if differ(oldState?.currentPlaylistIndex, state.currentPlaylistIndex) || // Check enabled state: we have playlists and selected playlist
                       differ(oldState?.currentPlayist, state.currentPlayist) {
                self?.setEnabled(isAllEnabled: state.currentPlaylistIndex != nil && state.currentPlayist.count > 0);
            }

            if differ(oldState?.isPlayingMode, state.isPlayingMode) { // Toggle play/pause button
                self?.setPlayPauseButton(isPlaying: state.isPlayingMode);
            }

            if differ(oldState?.currentVolume, state.currentVolume) { // Restore volume slider position
                self?.volumeSlider.value = state.currentVolume;
            }
        }
    }

}
