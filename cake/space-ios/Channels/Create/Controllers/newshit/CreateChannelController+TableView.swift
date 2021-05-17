//
//  CreateChannelController+TableView.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-05-15.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

//extension CreateChannelController {
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let headerCell = tableView.dequeueReusableCell(withIdentifier: channelNameHeaderCellId, for: indexPath) as? ChannelNameHeaderCell ?? ChannelNameHeaderCell()
//        headerCell.delegate = self
//    }
//    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 50 // to change
//    }
//    
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 4
//    }
//    
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if section == 0 {
//            return 1
//        } else if section == 1 {
//            return secondSection.count
//        } else if section == 2 {
//            return thirdSection.count
//        } else {
//            return fourthSection.count
//        }
//    }
//}
