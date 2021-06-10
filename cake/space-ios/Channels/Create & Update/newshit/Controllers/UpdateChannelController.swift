//
//  UpdateChannelController_.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-05-08.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit

class UpdateChannelController: CreateChannelController {
    
    override func createChannel() {
        print("updating channel")
    }
    
    override func configureNavigationBar() {
        title = "Update event"
        
        let doneEditingButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(createChannel))
        navigationItem.rightBarButtonItem = doneEditingButton
        navigationItem.rightBarButtonItem?.isEnabled = false
        // navigationItem.rightBarButtonItem?.tintColor = .lightText
    }
    
    override func configureDates() {
        dateFormatter.dateFormat = "MMMM d, yyyy"
        timeFormatter.dateFormat = "h:mm a"
    }
}
