//
//  UploadProgress.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-11-19.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit

class UploadProgress: NSObject {
  var objectID: String
  var progress: Double
  
  init(objectID: String, progress: Double) {
    self.objectID = objectID
    self.progress = progress
  }
}

extension Array where Element: UploadProgress {
  
  mutating func setProgress(_ progress: Double, id: String) {
    var array = self as [UploadProgress]
    
        guard let index = array.firstIndex(where: { (element) -> Bool in
      return element.objectID == id
    }) else {
      let element = UploadProgress(objectID: id, progress: progress)
      array.insert(element, at: 0)
      self = array as! Array<Element>
      return
    }
    array[index].progress = progress
    self = array as! Array<Element>
  }
}
