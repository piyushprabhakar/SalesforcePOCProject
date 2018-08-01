//
//  ContactListVC.swift
//  TestApp
//
//  Created by Piyush on 27/10/16.
//  Copyright © 2016 Salesforce. All rights reserved.
//

import UIKit
import SmartStore
import SmartSync


class ContactListVC: UIViewController {
    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    // SFSmartSyncSyncManager.sharedInstance(SFUserAccountManager.sharedInstance().currentUser)
    @IBOutlet weak var email: UITextField!
    var syncMgr: SFSmartSyncSyncManager!
    let soupName = "Contact"
    let orderByFieldName = "LastName"
    var result: [Any]? = nil
    let reachability = Reachability()!
    var contactDataSource:[ContactDataModel] = []
    var syncState: SFSyncState? = nil
    
    let queue = OperationQueue()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        syncMgr = SFSmartSyncSyncManager.sharedInstance(forUser: SFUserAccountManager.sharedInstance().currentUser, storeName: "abcd")
        //declare this inside of viewWillAppear
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged),name: ReachabilityChangedNotification,object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
        
        self.getContactData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reachabilityChanged(note: NSNotification) {
        
        let reachability = note.object as! Reachability
        
        if reachability.isReachable {
            if reachability.isReachableViaWiFi {
                print("Reachable via WiFi")
            } else {
                print("Reachable via Cellular")
            }
        } else {
            print("Network not reachable")
        }
    }
    
    @IBAction func didTapDeleteButton(_ sender: UIButton) {
        
        //        store().removeAllSoups()
        
        // let sqlQuery = "SELECT * from {Contact}"
        
        let querySpec = SFQuerySpec.newAllQuerySpec(soupName, withOrderPath: "FirstName", with: .ascending, withPageSize: 10000)
        result = try! store().query(with: querySpec, pageIndex: 0)
        print(result)
        for index in 0...(result?.count)! - 1 {
            
            var dict: [String: Any] = result![index] as! Dictionary
            print(" first name = \(dict["FirstName"]) ,Mobile No = \(dict["MobilePhone"])")
        }
        
        
    }
    @IBAction func didTapDemoButton(_ sender: UIButton) {
        
        let vc = SFSmartStoreInspectorViewController.init(store: store())
        self.navigationController?.present(vc!, animated: true, completion: nil)
//        vc?.present(self, animated: true, completion: nil)
    }
    
    @IBAction func didTapSyncButton(_ sender: AnyObject) {
        
        syncDown()
    }
    
    func syncDown() {
        
        if !store().soupExists(soupName) {
            
            registerSoup()
        }
        
        
        // let queryString = "SELECT Id, FirstName,LastName,Title,MobilePhone,Email,Department,HomePhone FROM Contact"
        let queryString = "SELECT Id,FirstName,LastName,Title,MobilePhone,Email FROM Contact"
        
        let syncOptions = SFSyncOptions.newSyncOptions(forSyncDown: .leaveIfChanged)
        
        let syncTarget = SFSoqlSyncDownTarget.newSyncTarget(queryString)
        
        syncState = syncMgr?.syncDown(with: syncTarget, options: syncOptions, soupName: soupName, update: { (state) in
            
                print(state?.syncId)
                self.getContactData()
            
        })
        
        
        
    }
    
    @IBAction func didTapSaveToStore(_ sender: UIButton) {
        
        // upsertInDB()
        
        let id = contactDataSource[0].id!
//        let soupEntryID = contactDataSource[0].soupEntryID!
        
        var dataSpec:[String:Any] = [:]
        
        dataSpec["FirstName"] = "p3000"
        dataSpec["Email"] = "piyush@cts.com"
        dataSpec["LastName"] = "Piyush"
        dataSpec["type"] = "locally"
        dataSpec["Id"] = id
//        dataSpec["_soupEntryId"] = 1
//        if let value = contactDataSource[0].lastModifiedDate {
//            dataSpec["LastModifiedDate"] = value
//            
//        }
        //let attributes = ["type":"Contact","url":"/services/data/v36.0/sobjects/Contact/0032800000lMccaAAC"]
//        let url = contactDataSource[0].attributesURL!
        let attributes = ["type":"Contact"]
        //let attributes = ["type":"Contact","url":url]

        
        dataSpec["__local__"] = true
        dataSpec["__locally_created__"] = false
        dataSpec["__locally_updated__"] = true
        dataSpec["__locally_deleted__"] = false
        //
        
        
        dataSpec["attributes"] = attributes
        
//                store().upsertEntries([dataSpec], toSoup: soupName)
        do {
            let a = try store().upsertEntries([dataSpec], toSoup: soupName, withExternalIdPath: "Id")
            print(a)
        }catch {
            
            print(error.localizedDescription)
        }
        
        print(id)
    }
    
    
    @IBAction func didTapSyncUp(_ sender: UIButton) {
        
   
        //  ############### Create Record on servr
       
        let fieldList = ["Id","FirstName","Email","LastName"]
        let syncOptions = SFSyncOptions.newSyncOptions(forSyncUp: fieldList, mergeMode: .overwrite)
        _ = syncMgr.syncUp(with: syncOptions, soupName: soupName, update: { (state) in
            
            if let done = state?.isDone(), let failed = state?.hasFailed(), done || failed {
                print(done)
                if failed{
                    print("Failed")
                    self.getCallsCount(successBlock: { (count) in
                        
                        if count > 0 {
                            let query = "SELECT * from {Contact} where {Contact:__local__} = '1' ORDER BY {Contact:_soupEntryId}"
                            let sobjectsQuerySpec = SFQuerySpec.newSmartQuerySpec(query, withPageSize: 1)
                            self.store().removeEntries(byQuery: sobjectsQuerySpec, fromSoup: self.soupName)
                            self.syncUP()
                        }
                    })
                    
                }
            }
        })
       
        
    }
    
    func syncUP(){
        let fieldList = ["Id","FirstName","Email","LastName"]
        let syncOptions = SFSyncOptions.newSyncOptions(forSyncUp: fieldList, mergeMode: .overwrite)
        _ = syncMgr.syncUp(with: syncOptions, soupName: soupName, update: { (state) in
    
            if let done = state?.isDone(), let failed = state?.hasFailed(), done || failed {
                
                if failed{
                    self.getCallsCount(successBlock: { (count) in
                        
                        if count > 0 {
                            let query = "SELECT * from {Contact} where {Contact:__local__} = '1' ORDER BY {Contact:_soupEntryId}"
                            let sobjectsQuerySpec = SFQuerySpec.newSmartQuerySpec(query, withPageSize: 1)
                            self.store().removeEntries(byQuery: sobjectsQuerySpec, fromSoup: self.soupName)
                            self.syncUP()
                        }
                    })
    
        }
                if done{
                    
                    print("Completed")
                }
                
            }
        })
    
    }
    
    
    
    func getContactData() {
        
        //Dynamic Query
        
        let query = "SELECT * from {Contact}"
        
        let sobjectsQuerySpec = SFQuerySpec.newSmartQuerySpec(query, withPageSize: 1000)
        do {
            
            let result = try store().query(with: sobjectsQuerySpec, pageIndex: 0)
            
            // print(result)
            for aContact in result {
                let contactDataModel = ContactDataModel.init(data: aContact)
                contactDataSource.append(contactDataModel)
            }
            
            //            print(resultData)
            //            print(resultData.count)
            //            triggerSyncUpOperation(contactData: resultData)
            
        }catch {print(error)}
        
        
    }
    
    @IBAction func deleteSoup(_ sender: UIButton) {
        
        store().removeSoup(soupName)
    }
    
    func deleteSoupWith(soupEntryId: Int) {
        
        store().removeEntries([soupEntryId], fromSoup: soupName)
    }
    
    func upsertInDB() {
        
        let attributes = ["type":"Contact"]
        var dataDict:[String:Any] = [:]
        
        dataDict["attributes"] = attributes
        dataDict["FirstName"] = "lohit"
        dataDict["Email"] = "abc@lohit.com"
        dataDict["LastName"] = "Kumar"
        dataDict["Id"] = "local_x"
         dataDict["type"] = "locally_created"
        dataDict["__local__"] = true
        dataDict["__locally_created__"] = true
        dataDict["__locally_updated__"] = false
        dataDict["__locally_deleted__"] = false
        store().upsertEntries([dataDict], toSoup: soupName)
    }
    
    func store() -> SFSmartStore {
        
        return SFSmartStore.sharedStore(withName:
            "abcd") as! SFSmartStore
    }
    
    func registerSoup() {

        let id =  ["path": "Id", "type": kSoupIndexTypeString]
        let firstName =  ["path": "FirstName", "type": kSoupIndexTypeString]
        let lastName =  ["path": "LastName", "type": kSoupIndexTypeString]
        let title =  ["path": "Title", "type": kSoupIndexTypeString]
        let phone =  ["path": "MobilePhone", "type": kSoupIndexTypeString]
        let email =  ["path": "Email", "type": kSoupIndexTypeString]
        let dept =  ["path": "Department", "type": kSoupIndexTypeString]
        let homePhone =  ["path": "HomePhone", "type": kSoupIndexTypeString]
        let type =  ["path": "type", "type": kSoupIndexTypeString]
        let lastModifiedDate =  ["path": "LastModifiedDate", "type": kSoupIndexTypeString]


        let local =  ["path": "__local__", "type": kSoupIndexTypeString]
        
        
        
        let accountindexSpec = SFSoupIndex.asArraySoupIndexes([id, firstName, lastName, title, phone, email, dept, homePhone,local,type,lastModifiedDate])
        
        do {
            //registerSoup
            
            try self.store().registerSoup(soupName, withIndexSpecs: accountindexSpec, error: ())
            print("store created")
            
            // Insert Data In soup
            //                let updatedEntries = store?.upsertEntries(responseData, toSoup: accountSoupName)
            //                print(updatedEntries)
            
        } catch let error as NSError {
            print("Can't crate soup \(error.localizedDescription)")
        }
    }
    
    @IBAction func dudTapSOQLQueryBtn(_ sender: UIButton) {
     
    }
    
    @IBAction func didTapSaveInDB(_ sender: Any) {
        
        let attributes = ["type":"Contact"]
        var dataDict:[String:Any] = [:]
        
        dataDict["attributes"] = attributes
        dataDict["FirstName"] = firstName.text!
        dataDict["Email"] = email.text!
        dataDict["LastName"] = lastName.text!
        dataDict["Id"] = "local_x"
        dataDict["__local__"] = true
        dataDict["__locally_created__"] = true
        dataDict["__locally_updated__"] = false
        dataDict["__locally_deleted__"] = false
        store().upsertEntries([dataDict], toSoup: soupName)
    }
    
    //MARK:- Batch Request
    
    @IBAction func batchRequest(_ sender: UIButton) {
      /*
        let dict1 = ["method":"GET","url":"v39.0/query?q=SELECT+count()+FROM+Account"]
        let dict2 = ["method":"GET","url":"v39.0/query?q=SELECT+count()+FROM+Contact"]
        let resopnseDict: [Any] = [dict1,dict2]

        
        let requestBody = ["batchRequests":resopnseDict]
        
       print(requestBody)

        let jsonDict = convertDictionaryIntoJSONDictionary(dictionary: requestBody)
        print(jsonDict)
      
        let request = SFRestAPI.sharedInstance().requestForResources()
        let query = request.path + "/composite/batch/"
        let restReq = SFRestRequest(method: .GET, path: query, queryParams: nil)
        restReq.setCustomRequestBodyDictionary(jsonDict, contentType: "application/json")
        

        
//        SFRestAPI.sharedInstance().send(restReq, fail: { (error) in
//            print(error?.localizedDescription as Any)
//        }) { (response) in
//            let responceDict = response as? [String: AnyObject]
//            print(responceDict as Any)
//        }
        
        
      
*/
        let restRequest1:SFRestRequest = SFRestRequest()
        restRequest1.method = .GET
        restRequest1.path = SFRestAPI.sharedInstance().apiVersion+"/query?q=SELECT+count()+FROM+Contact"
        
        let restRequest2:SFRestRequest = SFRestRequest()
        restRequest2.method = .GET
        restRequest2.path = SFRestAPI.sharedInstance().apiVersion+"/query?q=SELECT+count()+FROM+Account"
        
        let restRequest3:SFRestRequest = SFRestRequest()
        restRequest3.method = .GET
        restRequest3.path = SFRestAPI.sharedInstance().apiVersion+"/query?q=SELECT+count()+FROM+User"
        

        let compositeRequest = SFRestAPI.sharedInstance().batchRequest([restRequest1,restRequest2,restRequest3], haltOnError: true)
        
        SFRestAPI.sharedInstance().send(compositeRequest, fail: { (error) in
            print(error?.localizedDescription as Any)
        }) { (response) in
            print(response as Any)
        }
        
    }
    
    func convertDictionaryIntoJSONDictionary(dictionary: [String:Any]) -> [String:Any] {
        var jsonDict:[String:Any] = [:]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
            // here "jsonData" is the dictionary encoded in JSON data
            
            let decoded = try JSONSerialization.jsonObject(with: jsonData, options: [])
            // here "decoded" is of type `Any`, decoded from JSON data
            // you can now cast it with the right type
            if let dictFromJSON = decoded as? [String:Any] {
                jsonDict = dictFromJSON
            }
        } catch {
            print(error.localizedDescription)
        }
        return jsonDict
    }
    
    func getCallsCount(successBlock:(_ result: Int) -> Void) {
        
        
        let query = "Select count(*) from {Contact} where {Contact:__local__} = '1'"
        
        var count = 0
        
        let sobjectsQuerySpec = SFQuerySpec.newSmartQuerySpec(query, withPageSize: 1000)
        
        do {
             let results = try store().query(with: sobjectsQuerySpec, pageIndex: 0)
                let resultCount = results[0] as! [Int]
                count = resultCount[0]
                successBlock(count)
            
            
        } catch {
            let count = 0
            successBlock(count)
        }
        
    }

    @IBAction func logout(_ sender: Any) {
        
        SFAuthenticationManager.shared().logout()

    }
}


