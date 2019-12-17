//
//  ViewController.swift
//
//  Copyright (c) 2019 Evolv Technology Solutions
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit
import EvolvKit

/// This example shows how the data can be structured in your view controllers,
/// your implementation can work directly with the raw string and serialize into EvolvRawAllocation.
class ViewController: UIViewController {
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var checkoutButton: UIButton!
    
    private let evolvClient = EvolvClientHelper.shared.client
    
    @IBAction func didPressCheckOut(_ sender: Any) {
        evolvClient.emitEvent(forKey: "conversion")
        textLabel.text = "Conversion!"
    }
    
    @IBAction func didPressProductInfo(_ sender: Any) {
        textLabel.text = "Some really cool product info"
    }
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true

		// MARK: Evolv subscribe
        evolvClient.subscribe(forKey: "checkout.button.background.color", defaultValue: __N("#000000"), closure: setBackgroundColor)
		evolvClient.subscribe(forKey: "product.view.background.color", defaultValue: __N("#FFFFFF"), closure: setCheckoutButtonColor)
        evolvClient.subscribe(forKey: "checkout.button.text", defaultValue: __N("BUY NOW"), closure: setCheckoutButtonText)
        evolvClient.confirm()
    }

    /// Trailing closure example that will apply the treatments from the allocation.
    ///
    /// - Parameter layoutOption: Implementer decides what the data type will be.
    ///   Needs to match subscribe method's default value data type.
    /// - Use DispatchQueue to ensure this operation runs on the UI thread
    lazy var changeButtonText: (EvolvRawAllocationNode) -> Void = { buttonTextOption in
        DispatchQueue.main.async { [weak self] in
			self?.checkoutButton.setTitle(buttonTextOption.stringValue, for: .normal)
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
    func setBackgroundColor(_ layoutOption: EvolvRawAllocationNode) {
        DispatchQueue.main.async { [weak self] in
			DispatchQueue.main.async { [weak self] in
				let color = layoutOption.stringValue;
				self?.view.backgroundColor = UIColor(hex: color)
			}
        }
    }
	
	func setCheckoutButtonColor(_ layoutOption: EvolvRawAllocationNode) {
		DispatchQueue.main.async { [weak self] in
			let color = layoutOption.stringValue;
			self?.checkoutButton.backgroundColor = UIColor(hex: color)
		}
	}
	
	// focus on text, mention color
	func setCheckoutButtonText(_ buttonTextOption: EvolvRawAllocationNode) {
        DispatchQueue.main.async { [weak self] in
			self?.checkoutButton.setTitle(buttonTextOption.stringValue, for: .normal)
			self?.checkoutButton.titleLabel?.font = .systemFont(ofSize: 24)
        }
	}

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
}
