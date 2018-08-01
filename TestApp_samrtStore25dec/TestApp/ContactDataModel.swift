//
//  ContactDataModel.swift
//  TestApp
//
//  Created by Piyush on 25/12/16.
//  Copyright © 2016 Salesforce. All rights reserved.
//

import UIKit

struct ContactDataModel {
    
    var firstName: String?
    var lastName: String? 
    var email: String? 
    var id: String? 
    var soupEntryID: Int? 
    var soupName: String?
    var lastModifiedDate: String?
    var attributesType: String?
    var attributesURL: String?


    init(data: Any) {
        
        if let data = data as? [AnyObject] {
            
            let valueDict = data[1] as? [String: AnyObject]
             print(valueDict?["Id"])
            if let value = valueDict?["Id"] {
                
                id = value as? String
            }
            
            if let value = valueDict?["FirstName"] {
                
                firstName = value as? String
            }
            
            if let value = valueDict?["LastName"] {
                
                lastName = value as? String
            }
            
            if let value = valueDict?["Email"] {
                
                email = value as? String
            }
            
            if let value = valueDict?["_soupEntryId"] {
                
                soupEntryID = value as? Int
            }
            
            if let value = valueDict?["LastModifiedDate"] {
                
                lastModifiedDate = value as? String
            }
            
            if let value = valueDict?["attributes"] as? [String: String] {
                
            
                    
                    attributesURL = value["url"]
                
                print(attributesURL)
                
                
            }
            
            
        }
    }

    
    
}
