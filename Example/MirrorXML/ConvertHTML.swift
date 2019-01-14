//
//  ConvertHTML.swift
//  MirrorXML_Example
//
//  Created by Mike Spears on 2019-01-14.
//  Copyright © 2019 samesimilar@gmail.com. All rights reserved.
//

import Foundation
import MirrorXML

class ConvertHTML : NSObject {
    @objc func attributedString() -> NSAttributedString {
        let html = try! String(contentsOf: Bundle.main.url(forResource: "markdownish", withExtension: "html")!)
        
        let parser = MXHTMLToAttributedString()
        let result = parser.convertHTMLString(html)
        for attachment in parser.imageAttachments {
            if let image = UIImage(named: attachment.src) {
                attachment.width = 300.0
                MXHTMLToAttributedString.insert(image, with: attachment, to: result)
            }
            
        }
        if let errors = parser.errors {
            print(errors)
        }
        
        return result
        
    }
}

