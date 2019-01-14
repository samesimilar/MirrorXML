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
}
