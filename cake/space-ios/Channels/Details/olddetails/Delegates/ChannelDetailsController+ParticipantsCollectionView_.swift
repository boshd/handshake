////
////  ChannelDetailsController+ParticipantsCollectionView.swift
////  space-ios
////
////  Created by Kareem Arab on 2020-10-13.
////  Copyright © 2020 Kareem Arab. All rights reserved.
////
//
//import UIKit
//
//extension ChannelDetailsController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return self.allParticipants.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = channelDetailsContainerView.participantsCollectionView.dequeueReusableCell(withReuseIdentifier: participantCellId, for: indexPath) as! ParticipantCell
//        cell.configureCell(for: indexPath, users: self.allParticipants)
//        return cell
//    }
//
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 50, height: 50)
//    }
//    
//}
