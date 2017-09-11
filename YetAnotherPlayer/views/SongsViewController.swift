//
// Created by Krupin Maxim
// Copyright (c) 2017 Maxim. All rights reserved.
//

import Foundation
import UIKit
import ReSwift
import MediaPlayer
import AELog

/** 
 * Table with songs
 */
class SongsViewController: UITableViewController {

    fileprivate var innerState: AppState? = nil;
    private static let cellIdentifier = "SongName";

    override func viewDidLoad() {
        super.viewDidLoad();
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);

        AppStoreHolder.store.subscribe(self);
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);

        AppStoreHolder.store.unsubscribe(self);
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return innerState?.currentPlayist.count ?? 0;
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true;
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            AppStoreHolder.store.dispatch(.RemoveMediaItem(index: indexPath.row));
        }
    }

    override func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        self.restoreSelection();
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SongsViewController.cellIdentifier, for: indexPath);
        cell.textLabel?.text = innerState?.currentPlayist[indexPath.row].title;
        cell.detailTextLabel?.text = innerState?.currentPlayist[indexPath.row].artist;
        return cell;
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AppStoreHolder.store.dispatch(.SelectSong(index: indexPath.row));
    }

    @IBAction func addButtonHandler(_ sender: UIBarButtonItem) {
        self.showMediaPicker();
    }

    func restoreSelection() {
        if let currentSongIndex = innerState?.currentSongIndex {
            self.selectRowAt(index: currentSongIndex);
        }
    }

}

// --------------------------- All about state

extension SongsViewController: ReSwift.StoreSubscriber {

    func newState(state: AppState) {
        DispatchQueue.main.async { [weak self] in
            let oldState = self?.innerState;
            self?.innerState = state;

            if differ(oldState?.currentPlaylistIndex, state.currentPlaylistIndex) { // Set title for table
                if let curIndex = state.currentPlaylistIndex, curIndex < state.playlists.count {
                    let name = state.playlists[curIndex].name;
                    self?.navigationItem.title = name;
                }
            }

            if differ(oldState?.currentPlayist, state.currentPlayist) { // Show songs in table
                self?.tableView.reloadData();
            }

            if differ(oldState?.currentSongIndex, state.currentSongIndex) { // Show current song in table
                if let index = state.currentSongIndex {
                    self?.selectRowAt(index: index);
                } else {
                    self?.deselectRow();
                }
            }
        }
    }

}

// -------------------------- All about media picker

extension SongsViewController: MPMediaPickerControllerDelegate {

    /**
    * Show for choose songs, just change pickerMode in state
    */
    func showMediaPicker() {
        let myMediaPicker = MPMediaPickerController(mediaTypes: MPMediaType.music);
        myMediaPicker.allowsPickingMultipleItems = true;
        myMediaPicker.delegate = self;
        AppStoreHolder.store.dispatch(.MediaPickerMode(isOn: true));
        self.present(myMediaPicker, animated: true, completion: nil);
    }

    /**
    * Handle selected, dispatch items and change pickerMode in state
    */
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        AppStoreHolder.store.dispatch(.AddMediaItems(items: Set(mediaItemCollection.items)));
        mediaPicker.dismiss(animated: true, completion: { [weak self] in
            self?.restoreSelection();
            AppStoreHolder.store.dispatch(.MediaPickerMode(isOn: false));
        });
    }
    
    /**
    *  Handle cancel selection, just change pickerMode in state
    */
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        mediaPicker.dismiss(animated: true, completion: { [weak self] in
            self?.restoreSelection();
            AppStoreHolder.store.dispatch(.MediaPickerMode(isOn: false));
        })
    }

}
