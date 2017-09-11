//
// Created by Maxim on 09/09/17.
// Copyright (c) 2017 Maxim. All rights reserved.
//

import Foundation
import AELog

/**
 * Data for store in preferences.
 * It holds playlists and volume.
 */
class PreferencesData: NSObject, NSCoding {

    var playlists: [PlaylistData] = [];
    var volume: Float = 1.0;

    init(playlists: [PlaylistData], volume: Float) {
        self.playlists = playlists;
        self.volume = volume;
    }

    required convenience init?(coder aDecoder: NSCoder) {
        guard let playlists = aDecoder.decodeObject(forKey: "playlists") as? [PlaylistData]
                else {
            aelog("Playlists is nil");
            return nil
        }
        let volume = aDecoder.decodeFloat(forKey: "volume");
        self.init(playlists: playlists, volume: volume);
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.playlists, forKey: "playlists");
        aCoder.encode(self.volume, forKey: "volume");
    }


}
