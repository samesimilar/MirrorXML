//
//  ReadOPML.swift
//  MirrorXML_Example
//
//  Created by Mike Spears on 2019-01-14.
//  Copyright © 2019 samesimilar@gmail.com. All rights reserved.
//

import Foundation
import MirrorXML

class OPMLItem : NSObject{
    @objc let title: String
    @objc let itemDescription: String?
    @objc let htmlUrl: String?
    init(title: String, description: String?, htmlUrl: String? ) {
        self.title = title
        self.itemDescription = description
        self.htmlUrl = htmlUrl
    }

}
class RSSItem {
    var title: String?
    var link: String?
}
class ReadOPML : NSObject {
    @objc func readOPML() -> [OPMLItem] {
        
        var items = [OPMLItem]()
        
        let outline = try! MXMatch(path:"/opml/body//outline")
        outline.entryHandler = { (elm) in
            
            if let title = elm.lowercasedAttributes["text"] {
                let item = OPMLItem(title: title, description: elm.lowercasedAttributes["description"], htmlUrl: elm.lowercasedAttributes["htmlurl"])
                items.append(item)
            }
            
            return nil
        }
        
        
        let parser = MXParser(matches: [outline])
        
        let data = try! Data(contentsOf: Bundle.main.url(forResource: "subscriptionList", withExtension: "opml")!)
        
        parser.parseDataChunk(data)
        parser.dataFinished()
        
        return items
 
    }
    
    func test() {
        
        var items = [RSSItem]()
        let itemMatch = try! MXMatch(path: "/rss/channel/item")
        
        // Create a block that will be called at the beginning of every item element.
        itemMatch.entryHandler = {(elm) in
            //create a new instance of the RSSItem class
            // but don't add it to the storage array until later
            let thisRSSItem = RSSItem()
            
            let titleMatch = try! MXMatch(path: "/title")
            titleMatch.exitHandler = { (elm) in
                thisRSSItem.title = elm.text
            }
            let linkMatch = try! MXMatch(path: "/link")
            titleMatch.exitHandler = { (elm) in
                thisRSSItem.link = elm.text
            }
            
            // Only add the item if it is valid.
            // This block will run after titleMatch and linkMatch.
            // Note that in this circumstance we have a reference to the 'thisRSSItem' object we are building.
            let itemExit = MXMatch.onRootExit({ (elm) in
                guard thisRSSItem.title != nil && thisRSSItem.link != nil else {
                    return
                }
                items.append(thisRSSItem)
            })
            // Return the temporary MXMatch objects. They will only apply to the current 'item' element.
            return [titleMatch, linkMatch, itemExit]
        }
    }
}
