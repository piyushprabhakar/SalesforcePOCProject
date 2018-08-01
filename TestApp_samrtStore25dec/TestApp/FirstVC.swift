//
//  FirstVC.swift
//  TestApp
//
//  Created by Piyush on 10/25/16.
//  Copyright © 2016 Salesforce. All rights reserved.
//

import UIKit
import SmartStore
import SmartSync

class FirstVC: UIViewController {

    var store: SFSmartStore!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        store = SFSmartStore.sharedStore(withName: kDefaultSmartStoreName) as! SFSmartStore!
//        let request = SFRestAPI.sharedInstance().request(forQuery: "SELECT Name, Id, OwnerId FROM Account")
//        
//        SFRestAPI.sharedInstance().send(request, delegate: self)
        
        print(SFUserAccountManager.sharedInstance().currentUser)
        print(self.navigationController?.topViewController)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK: - Smart store
    /*
    func saveDataInSmartStore(responseData: [Any]){
        
        // print(dataArray)
        
        
        let defaultStoreName = "AccountStore"
        store = SFSmartStore.sharedStore(withName: defaultStoreName) as? SFSmartStore
        store?.removeAllSoups()
        
        let exist = store?.soupExists(defaultStoreName)
        let accountSoupName = "AccountSoup"
        
        print(store?.storePath)
        
        // Creating index spec which consist of name, path and type
        let nameDictionary =  ["path": "Name", "type": kSoupIndexTypeString]
        let idValuesDict = ["path": "Id", "type": kSoupIndexTypeString]
        let attributesValuesDict = ["path": "attributes", "type": kSoupIndexTypeString]
        
        let accountindexSpec = SFSoupIndex.asArraySoupIndexes([nameDictionary, idValuesDict, attributesValuesDict])
        
        
        if !exist! {
            
            do {
                //registerSoup
                
                try store?.registerSoup(accountSoupName, withIndexSpecs: accountindexSpec, error: ())
                print("store created")
                
                // Insert Data In soup
                let updatedEntries = store?.upsertEntries(responseData, toSoup: accountSoupName)
                print(updatedEntries)
                
            } catch let error as NSError {
                print("Can't crate soup \(error.localizedDescription)")
            }
        }        
 
        // SOQL Queary inspector
        
        let vc = SFSmartStoreInspectorViewController.init(store: store)
        vc?.present(self)
        
        
        
        
        
        
    }
        */
    //MARK: - Demo Button Action

    @IBAction func didTapDemoButton(_ sender: UIButton) {
        
        let vc = SFSmartStoreInspectorViewController.init(store: store)
        vc?.present(vc!, animated: true, completion: nil)

    }
    
    @IBAction func didTapSyncButton(_ sender: UIButton) {
        
//        let soqlQuearyString = "SELECT Name, Id, OwnerId FROM Account"
//        
//        let syncTarget = SFSyncTarget()
//        
//        
        
    }
    
    
    
}

extension FirstVC: SFRestDelegate {
    
    internal func request(_ request: SFRestRequest, didLoadResponse dataResponse: Any) {
        
        print(dataResponse)
        
        let responseDict = dataResponse as? NSDictionary
        
        _ = responseDict?["records"] as? [Any]
        //
        //        print(dataArray?.count)
        //        print(dataArray?[0] as? Dictionary<String,Any>)
        
        
     ////   saveDataInSmartStore(responseData: dataArray!)
        
        
        //
        
        
    }
    
    
    
    func request(_ request: SFRestRequest, didFailLoadWithError error: Error)
    {
        self.log(.debug, msg: "didFailLoadWithError: \(error)")
        // Add your failed error handling here
    }
    
    func requestDidCancelLoad(_ request: SFRestRequest)
    {
        self.log(.debug, msg: "requestDidCancelLoad: \(request)")
        // Add your failed error handling here
    }
    
    func requestDidTimeout(_ request: SFRestRequest)
    {
        self.log(.debug, msg: "requestDidTimeout: \(request)")
        // Add your failed error handling here
    }

    
}
