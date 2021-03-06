//
//  PremiumCheckoutViewController.swift
//  Sentiment Bot
//
//  Created by Moin Uddin on 1/19/19.
//  Copyright © 2019 Scott Bennett. All rights reserved.
//

import UIKit
import Stripe

class PremiumCheckoutViewController: UIViewController, STPAddCardViewControllerDelegate, ManagerProtocol {
    var user: User?
    
    var teamResponses: [Response]?
    
    var team: Team?
    
    var survey: Survey?
    
    var teamMembers: [User]?
    
    
    @IBOutlet weak var msgBox: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.title = "Standard"
        msgBox.text = ""
        if (user?.subscribed)! {
            subscribeButton.isHidden = true
        } else {
            cancelButton.isHidden = true
        }
        // Do any additional setup after loading the view.
    }

    
    @IBAction func cancelSubscription(_ sender: Any) {
        StripeController.shared.cancelPremiumSubscription { (errorMessage) in
            
        }
    }
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var subscribeButton: UIButton!
    
    @IBAction func subscribe(_ sender: UIButton) {
        // Setup add card view controller
        let addCardViewController = STPAddCardViewController()
        addCardViewController.delegate = self
        addCardViewController.title = "Subscribe to Premium"
        
        
        // Present add card view controller
        let navigationController = UINavigationController(rootViewController: addCardViewController)
        present(navigationController, animated: true)
    }
    
    // MARK: STPAddCardViewControllerDelegate
    
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        // Dismiss add card view controller
        dismiss(animated: true)
    }
    
    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: @escaping STPErrorBlock) {
        dismiss(animated: true)
        title = "Subscribe to Premium"
        print("Printing Strip response:\(token.allResponseFields)\n\n")
        print("Printing Strip Token:\(token.tokenId)")
        
        msgBox.text = "Transaction success! \n\nHere is the Token: \(token.tokenId)\nCard Type: \(token.card!.funding.rawValue)\n\nSend this token or detail to your backend server to complete this payment."
        
        StripeController.shared.subscribeToPremium(token: token.tokenId)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
