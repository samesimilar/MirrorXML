//
//  SwiftTest.swift
//  MirrorXML_Example
//
//  Created by Mike Spears on 2018-02-15.
//  Copyright © 2018 samesimilar@gmail.com. All rights reserved.
//

import Foundation
import MirrorXML

public class SwiftTest : NSObject {
    func test() {
        
        let ownerName = MXMatch(path: "/opml/head/ownerName")!
        ownerName.exitHandler = { print($0.text ?? "")}
        
        
        
        let parser = MXParser(matches: [ownerName])
        
        let data = try! Data(contentsOf: Bundle.main.url(forResource: "subscriptionList", withExtension: "opml")!)
        
        parser.parseDataChunk(data)
        parser.dataFinished()
        
        
    }
}
