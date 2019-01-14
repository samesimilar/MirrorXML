//
//  ReadOPML.swift
//  MirrorXML_Example
//
//  Created by Mike Spears on 2019-01-14.
//  Copyright © 2019 samesimilar@gmail.com. All rights reserved.
//
/*
 Copyright (c) 2018 Michael Spears <help@samesimilar.com>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */
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

/**
 Basic idea for parsing an xml (OPML) file. Note that it doesn't preserve nested structures (all Outline elements are flattened into a single list.
 
 See ReadPLIST for an example of reading a document with arbitrary depth.
*/
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
