//
//  ViewController.swift
//  EvolvKit
//
//  Created by PhyllisWong on 07/03/2019.
//  Copyright (c) 2019 PhyllisWong. All rights reserved.
//

import UIKit
import EvolvKit
import SwiftyJSON
import Alamofire
import PromiseKit


class ViewController: UIViewController {
  
  @IBOutlet weak var textLabel: UILabel!
  
  let store = DefaultAllocationStore(size: 1000)
  var allocations = [JSON]()
  var client : EvolvClientProtocol?
  
  @IBAction func didPressCheckOut(_ sender: Any) {
    let key = getJsonData()
    if key.count > 0 {
      self.textLabel.text = "Conversion!"
    }
  }
  
  @IBAction func didPressProductInfo(_ sender: Any) {
    self.textLabel.text = "Some really cool product info!"
  }
  
  // This is also necessary when extending the superclass.
  required init?(coder aDecoder: NSCoder) {
    let envId = "40ebcd9abf"
    let httpClient = EvolvHttpClient()
    let config = EvolvConfig.builder(environmentId: envId, httpClient: httpClient).build()
    let participant = EvolvParticipant.builder().build()
    self.client = EvolvClientFactory(config: config, participant: participant).client as! EvolvClientImpl
    super.init(coder: aDecoder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    guard let statusBarView = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
    statusBarView.backgroundColor = UIColor(red: 0.0, green: 0.3, blue: 0.3, alpha: 1.0)
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
}

private extension ViewController {
  
  private func getJsonData() -> String {
    guard let client = self.client else { return "" }
    let key = "button"
    // get this to execute on the main thread and change the UI
    func printStuff(value: Any) { print("DO STUFF with \(value)") }
    // Client makes the call to get the allocations
    let someValue = client.subscribe(key: key, defaultValue: "green", function: printStuff)
    print(someValue)
    client.emitEvent(key: key)
    return key
  }
}

