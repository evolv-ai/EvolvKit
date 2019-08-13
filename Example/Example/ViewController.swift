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
    
    var rawAllocations: [JSON] = []
    var client: EvolvClient
    var httpClient: EvolvHttpClient
    let store: EvolvAllocationStore
    
    @IBAction func didPressCheckOut(_ sender: Any) {
        client.emitEvent(forKey: "conversion")
        textLabel.text = "Conversion!"
    }
    
    @IBAction func didPressProductInfo(_ sender: Any) {
        textLabel.text = "Some really cool product info"
    }
    
    required init?(coder aDecoder: NSCoder) {
        /*
         When you receive the fetched json from the participants API, it will be as type String.
         If you use the EvolvHttpClient, the json will be parsed with SwiftyJSON
         (required data type for AllocationsStoreProtocol).
         
         This example shows how the data can be structured in your view controllers,
         your implementation can work directly with the raw string and serialize into SwiftyJSON.
         */
        
        self.store = CustomAllocationStore()
        httpClient = DefaultEvolvHttpClient()

        /// - Build config with custom timeout and custom allocation store
        // set client to use sandbox environment
        let config = EvolvConfig.builder(environmentId: "sandbox", httpClient: httpClient)
            .set(allocationStore: store)
            .build()
        
        // set error or debug logLevel for debugging
        config.set(logLevel: .error)
        
        /// - Initialize the client with a stored user
        /// fetches allocations from Evolv, and stores them in a custom store
        client = EvolvClientFactory(config: config, participant: EvolvParticipant.builder()
            .set(userId: "sandbox_user")
            .build()).client
        
        /// - Initialize the client with a new user
        /// - Uncomment this line if you prefer this initialization.
        // client = EvolvClientFactory(config: config) as! EvolvClientProtocol

        super.init(coder: aDecoder)
    }
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setStatusBar()

		// MARK: Evolv subscribe
        client.subscribe(forKey: "ui.layout", defaultValue: "#000000", closure: setBackgroundColor)
        client.subscribe(forKey: "ui.buttons.checkout.text", defaultValue: "BUY STUFF", closure: changeButtonText)
        client.confirm()
    }


    /// Trailing closure example that will apply the treatments from the allocation.
    ///
    /// - Parameter layoutOption: Implementer decides what the data type will be.
    ///   Needs to match subscribe method's default value data type.
    /// - Use DispatchQueue to ensure this operation runs on the UI thread
    lazy var changeButtonText: (String) -> Void = { buttonTextOption in
        DispatchQueue.main.async { [weak self] in
			self?.checkoutButton.setTitle(buttonTextOption, for: .normal)
			self?.checkoutButton.titleLabel?.font = .systemFont(ofSize: 24)
        }
    }
    
}

extension ViewController {

    /// Simple function example that will apply the treatments from the allocation.
    ///
    /// - Parameter layoutOption: Implementer decides what the data type will be.
    ///   Needs to match subscribe method's default value data type.
    /// - Use DispatchQueue to ensure this operation runs on the UI thread
    func setBackgroundColor(_ layoutOption: String) {
        DispatchQueue.main.async { [weak self] in
            switch layoutOption {
            case "option_1":
                self?.view.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 0.5, alpha: 1.0) // yellow
            case "option_2":
                self?.view.backgroundColor = UIColor(red: 0.6, green: 0.9, blue: 0.5, alpha: 1.0) // light green
            case "option_3":
                self?.view.backgroundColor = UIColor(red: 32 / 255, green: 79 / 255, blue: 79 / 255, alpha: 1) // dark green
            case "option_4":
                self?.view.backgroundColor = UIColor(red: 255 / 255, green: 176 / 255, blue: 198 / 255, alpha: 1) // pink
            default:
                self?.view.backgroundColor = UIColor(hexString: layoutOption) // black (control)
            }
        }
    }

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}

	func setStatusBar() {
		guard let statusBarView = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else {
			return
		}

		statusBarView.backgroundColor = UIColor(red: 0.0, green: 0.3, blue: 0.3, alpha: 1.0)
	}

}
