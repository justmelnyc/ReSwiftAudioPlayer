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
 * Table with playlists names. It is root controller in app
 */
class PlaylistsViewController: UITableViewController {

    private static let cellIdentifier = "PlaylistName";

    fileprivate var innerState: AppState? = nil;

    override func viewDidLoad() {
        super.viewDidLoad();
        checkForMusicLibraryAccess();
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
        return innerState?.playlists.count ?? 0;
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlaylistsViewController.cellIdentifier, for: indexPath);
        cell.textLabel?.text = innerState?.playlists[indexPath.row].name;
        return cell;
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let playlistIndex = indexPath.row;
        if let playlists = innerState?.playlists, playlistIndex < playlists.count {
            AppStoreHolder.store.dispatch(.SelectPlaylist(index: playlistIndex));
//            Navigation.pushPlaylistViewController(parent: self);
        }
    }

    override  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true;
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            AppStoreHolder.store.dispatch(.RemovePlaylist(index: indexPath.row));
        }
    }

    @IBAction func addButtonHandler(_ sender: UIBarButtonItem) {
        self.showNewPlaylistAlert();
    }

    private func showNewPlaylistAlert() {
        let curIndex = self.innerState?.playlists.count ?? 0;
        let defaultName = "New playlist #\(curIndex + 1)";

        let alert = UIAlertController(title: "New playlist", message: nil, preferredStyle: .alert);
        alert.addTextField { textField in
            textField.text = defaultName;
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel));
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] _ in
            let typedName = alert?.textFields?[0].text ?? defaultName;
            self.addPlaylist(newName: typedName);
        }));

        self.present(alert, animated: true, completion: nil);
    }

    private func addPlaylist(newName: String) {
        AppStoreHolder.store.dispatch(.AddPlaylist(name: newName));
        Navigation.pushPlaylistViewController(parent: self);
    }

}

// ------------------------------ All about state

extension PlaylistsViewController: ReSwift.StoreSubscriber {

    func newState(state: AppState) {
        DispatchQueue.main.async { [weak self] in
            let oldState = self?.innerState;
            self?.innerState = state;

            if differ(oldState?.playlists.map {$0.name}, state.playlists.map {$0.name}) { // Show playlists
                self?.tableView.reloadData();
            }
        }

    }

}

// --------------------------- All about access to media 

extension PlaylistsViewController {
    
    func checkForMusicLibraryAccess(andThen callback: (() -> Void)? = nil) {
        let status = MPMediaLibrary.authorizationStatus();
        aelog("Have status: \(status)");
        switch status {
        case .authorized:
            callback?();
        case .notDetermined:
            MPMediaLibrary.requestAuthorization { status in
                aelog("After request status: \(status)");
                if status == .authorized {
                    DispatchQueue.main.async {
                        callback?();
                    }
                }
            }
        case .restricted:
            // do nothing
            break;
        case .denied:
            let alert = UIAlertController(title: "Need Authorization", message: "Woldn't you like to autorize this app to use your music library?", preferredStyle: .alert);
            alert.addAction(UIAlertAction(title: "No", style: .cancel));
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                let url = URL(string: UIApplicationOpenSettingsURLString)!;
                UIApplication.shared.open(url);
            })
            self.present(alert, animated: true);
        }
    }
    
    
}
