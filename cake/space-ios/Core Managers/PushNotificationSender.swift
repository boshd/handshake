//
//  PushNotificationSender.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-12-12.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit

class PushNotificationSender {
    func sendPushNotification(to token: String, title: String, body: String) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = ["to" : token,
                                           "notification" : ["title" : title, "body" : body],
                                           "data" : ["user" : "test_id"]
        ]

        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAAGGFE6hk:APA91bHBh2KQH37CBDej7r24Uz_eh-WMQCPBS4zsg3v2fkU7g5_0eSOlXXAmFcnjPA-QIQKqoz5AUApdctx1H7g8tcuPOlnLJTA2TYCmXhVHA1oQaQdgsR6t6vpxxQsyBvwy2hh-Qlow", forHTTPHeaderField: "Authorization")

        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
}
