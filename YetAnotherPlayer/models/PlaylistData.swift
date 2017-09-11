//
// Created by Maxim on 09/09/17.
// Copyright (c) 2017 Maxim. All rights reserved.
//

import Foundation
import MediaPlayer

/**
 * Data for playilist, holds name and list of songs.
 * Can be encoded for store in preferences
 */
class PlaylistData : NSObject, NSCoding {

    let name: String;
    var songs: [MPMediaEntityPersistentID];

    init(name: String, songs: [MPMediaEntityPersistentID]) {
        self.name = name;
        self.songs = songs;
    }

    required convenience  init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObject(forKey: "name") as? String,
              let songs = aDecoder.decodeObject(forKey: "songs") as? [MPMediaEntityPersistentID]
                else { return nil }
        self.init(name: name, songs: songs);
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.songs, forKey: "songs")
    }

}
