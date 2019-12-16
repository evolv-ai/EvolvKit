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
        evolvClient.subscribe(forKey: "checkout.button.color", defaultValue: __N("#000000"), closure: setCheckoutButtonColor)
        evolvClient.subscribe(forKey: "checkout.button.text", defaultValue: __N("BUY STUFF"), closure: changeButtonText)
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
//    func setBackgroundColor(_ layoutOption: EvolvRawAllocationNode) {
//        DispatchQueue.main.async { [weak self] in
//            switch layoutOption.stringValue {
//            case "option_1":
//                self?.view.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 0.5, alpha: 1.0) // yellow
//            case "option_2":
//                self?.view.backgroundColor = UIColor(red: 0.6, green: 0.9, blue: 0.5, alpha: 1.0) // light green
//            case "option_3":
//                self?.view.backgroundColor = UIColor(red: 32 / 255, green: 79 / 255, blue: 79 / 255, alpha: 1) // dark green
//            case "option_4":
//                self?.view.backgroundColor = UIColor(red: 255 / 255, green: 176 / 255, blue: 198 / 255, alpha: 1) // pink
//            default:
//                self?.view.backgroundColor = .black // black (control)
//            }
//        }
//    }
	
		func setCheckoutButtonColor(_ layoutOption: EvolvRawAllocationNode) {
	        DispatchQueue.main.async { [weak self] in
				let color = layoutOption.stringValue;
				self?.view.backgroundColor = UIColor(hex: color)
	        }
	    }

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}

}

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}
