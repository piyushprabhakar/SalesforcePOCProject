/*
Copyright (c) 2015, salesforce.com, inc. All rights reserved.

Redistribution and use of this software in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:
* Redistributions of source code must retain the above copyright notice, this list of conditions
and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of
conditions and the following disclaimer in the documentation and/or other materials provided
with the distribution.
* Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
endorse or promote products derived from this software without specific prior written
permission of salesforce.com, inc.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import Foundation
//import SalesforceRestAPI
import SmartStore
import SmartSync
import SalesforceAnalytics
import SalesforceSDKCore

class RootViewController : UITableViewController, SFRestDelegate
{
    var dataRows = [NSDictionary]()
    
    // MARK: - View lifecycle
    override func loadView()
    {
        super.loadView()
        self.title = "Mobile SDK Sample App"
        
        let storyboard = UIStoryboard(name: "main", bundle: nil)
        let firstVC =  storyboard.instantiateViewController(withIdentifier: "FirstVC") as! FirstVC
        self.navigationController?.pushViewController(firstVC, animated: true)
        //Here we use a query that should work on either Force.com or Database.com
        //let request = SFRestAPI.sharedInstance().request(forQuery: "/services/data/v37.0/query/?q=SELECT+AccountId,AssistantName,AssistantPhone+FROM+Contact+LIMIT+10")
        //let request = SFRestAPI.sharedInstance().request(forQuery: "SELECT AccountId,AssistantName,AssistantPhone FROM Contact LIMIT 10")
        
       
    }
    
    // MARK: - SFRestAPIDelegate
    
         
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView?) -> Int
    {
        return 1
    }
    
    override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int
    {
        return self.dataRows.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cellIdentifier = "CellIdentifier"

        // Dequeue or create a cell of the appropriate type.
        var cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if (cell == nil)
        {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }
        
        // If you want to add an image to your cell, here's how.
        let image = UIImage(named: "icon.png")
        cell!.imageView!.image = image
        
        // Configure the cell to show the data.
        let obj = dataRows[(indexPath as NSIndexPath).row]
        cell!.textLabel!.text = obj["Name"] as? String
        
        // This adds the arrow to the right hand side.
        cell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        return cell!
    }
    
}
