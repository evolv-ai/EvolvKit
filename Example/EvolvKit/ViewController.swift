//
//  ViewController.swift
//  EvolvKit
//
//  Created by PhyllisWong on 07/03/2019.
//  Copyright (c) 2019 PhyllisWong. All rights reserved.
//

import UIKit
import SwiftyJSON
import EvolvKit


class ViewController: UIViewController {
  
  @IBOutlet weak var textLabel: UILabel!
  @IBOutlet weak var checkoutButton: UIButton!
  
//  let store : AllocationStoreProtocol
//  var allocations = [JSON]()
//  var client : EvolvClientProtocol
//  var httpClient: HttpProtocol
//  let LOGGER = Log.logger
  
  @IBAction func didPressCheckOut(_ sender: Any) {
    //client.emitEvent(key: "conversion")
    self.textLabel.text = "Conversion!"
  }
  
  @IBAction func didPressProductInfo(_ sender: Any) {
    self.textLabel.text = "Some really cool product info!"
  }
  
  // FIXME: Migrate setup to app delegate
  required init?(coder aDecoder: NSCoder) {
    /*
     When you receive the fetched json from the participants API, it will be as type String.
     If you use the EvolvHttpClient, the json will be parsed with SwiftyJSON (required data type for our implementation of the cache.
     This example shows how the data can be structured, your implementation can work directly with the raw String and serialize into Swift if you choose.
     Uncomment each option one at a time to see the UI change based on the allocation.
     */
    
    let option1 = "option_1"
    //let option3 = "option_3"
    //let option7 = "option_7"
    let myStoredAllocation = "[{\"uid\":\"sandbox_user\",\"eid\":\"experiment_1\",\"cid\":\"candidate_3\",\"genome\":{\"ui\":{\"layout\":\"option_1\",\"buttons\":{\"checkout\":{\"text\":\"\(option1)\",\"color\":\"#f3b36d\"},\"info\":{\"text\":\"오늘추천\",\"color\":\"#f3b36d\"}}},\"search\":{\"weighting\":3.5}},\"excluded\":true}]"
    // store = CustomAllocationStore()
    
    if let dataFromString = myStoredAllocation.data(using: String.Encoding.utf8, allowLossyConversion: false) {
      do {
        //self.allocations = try JSON(data: dataFromString).arrayValue
        // store.put(uid: "sandbox_user", allocations: self.allocations)
      } catch {
        //let message = "Error converting string json to SwiftyJSON"
        //LOGGER.log(.error, message: message)
      }
    }
    
    //httpClient = EvolvHttpClient()
    
    /// - Build config with custom timeout and custom allocation store
    // set client to use sandbox environment
//    let config = EvolvConfig.builder(environmentId: "sandbox", httpClient: httpClient)
//      .setEvolvAllocationStore(allocationStore: store)
//      .build()
    
    /// - Initialize the client with a stored user
    /// fetches allocations from Evolv, and stores them in a custom store
//    client = EvolvClientFactory(config: config, participant: EvolvParticipant.builder()
//      .setUserId(userId: "sandbox_user").build()).client as! EvolvClientImpl
    
    /// - Initialize the client with a new user
    /// - Uncomment this line if you prefer this initialization.
    // client = EvolvClientFactory(config: config) as! EvolvClientProtocol
    
    super.init(coder: aDecoder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    guard let statusBarView = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
    statusBarView.backgroundColor = UIColor(red: 0.0, green: 0.3, blue: 0.3, alpha: 1.0)
    
    
    //client.subscribe(key: "ui.layout", defaultValue: "#000000", function: setContentViewWith)
    
    //client.subscribe(key: "ui.buttons.checkout.text", defaultValue: "오늘의추천", function: changeButtonText)
    //client.confirm()
    
  }
  
  
  /// Example of a closure that will affect the UI
  lazy var changeButtonText : (String) -> () = { buttonTextOption in
    DispatchQueue.main.async {
      switch buttonTextOption {
      case "option_1":
        self.checkoutButton.setTitle("당일배송", for: .normal)
      case "option_2":
        self.checkoutButton.setTitle("Begin Checkout", for: .normal)
      case "option_3":
        self.checkoutButton.setTitle("Start Checkout Process", for: .normal)
      default:
        self.checkoutButton.setTitle("Checkout", for: .normal)
      }
    }
    print("FOO")
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
}

private extension ViewController {
  
  /// This function can be a simple function, a closure, or any execution that will apply the treatments from the allocation.
  ///
  /// - Parameter layoutOption: Implementer decides what the data type will be.
  ///   Needs to match subscribe method's default value data type.
  func setContentViewWith(_ layoutOption: String) -> () {
    // this operation needs to run on the UI thread
    DispatchQueue.main.async {
      switch layoutOption {
      case "option_1":
        self.view.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 0.5, alpha: 1.0)
        
      case "option_2":
        self.view.backgroundColor = UIColor(red: 0.6, green: 0.9, blue: 0.5, alpha: 1.0)
        
      case "option_3":
        self.view.backgroundColor = UIColor(red: 32/255, green: 79/255, blue: 79/255, alpha: 1)
        
      case "option_4":
        self.view.backgroundColor = UIColor(red: 59/255, green: 144/255, blue: 147/255, alpha: 1)
      default:
        self.view.backgroundColor = UIColor(hexString: layoutOption)
      }
    }
  }
  
}