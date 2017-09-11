//
// Created by Krupin Maxim
// Copyright (c) 2017 Maxim. All rights reserved.
//

import Foundation
import UIKit

/**
 * Helper for controllers creation
 * TODO: Generate it
 */
class Navigation {

    /**
    * Create SongsViewController and push it to navigationController
    */
    public static func pushPlaylistViewController(parent: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let controller = storyboard.instantiateViewController(withIdentifier: "SongsViewController");
        parent.navigationController?.pushViewController(controller, animated: true);
    }

}
