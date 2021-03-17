//
//  SetupMeetingController.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-01-20.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import SafariServices
import UIKit

class SetupMeetingController: UITableViewController {
    // https://zoom.us/oauth/authorize?response_type=code&client_id=oHISYySISru_VxZxUqBvqQ&redirect_uri=https://yourapp.com
    let url = "https://zoom.us/oauth/authorizehttps://zoom.us/oauth/authorize?response_type=code&client_id=oHISYySISru_VxZxUqBvqQ"
    let settingsCellId = "settingsCellId"
    
    var services = [( icon: UIImage(named: ""), title: "Zoom meeting", subtitle: "" )]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    
    fileprivate func configureTableView() {
        tableView.register(ServiceCell.self, forCellReuseIdentifier: settingsCellId)
    }
    
    fileprivate func present()  {
        guard let url = URL(string: url) else { return }
        var svc = SFSafariViewController(url: url)

        if #available(iOS 11.0, *) {
            let configuration = SFSafariViewController.Configuration()
            configuration.entersReaderIfAvailable = true
            svc = SFSafariViewController(url:url, configuration: configuration)
        }
        present(svc, animated: true, completion: nil)
    }
}

extension SetupMeetingController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: settingsCellId, for: indexPath) as? ServiceCell ?? ServiceCell()
        cell.textLabel?.text = services[indexPath.row].title
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        present()
    }
    
}
