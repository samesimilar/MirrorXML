//
//  SwiftTest.swift
//  MirrorXML_Example
//
//  Created by Mike Spears on 2018-02-15.
//  Copyright © 2018 samesimilar@gmail.com. All rights reserved.
//

import Foundation
import MirrorXML

class RSSItem {
    var title: String!
    var link: String!
}
public extension Date {
//    https://github.com/justinmakaila/NSDate-ISO-8601
    public static func ISOStringFromDate(date: NSDate) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        
        return dateFormatter.string(from: date as Date).appending("Z")
    }
    
    public static func dateFromISOString(string: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        return dateFormatter.date(from: string)
    }
}

public class SwiftTest : NSObject {
    @objc func readWiki() {
        
//        var docs = [(String, String)]()
        var numDocs = 0
        
        let doc = try! MXMatch(path: "/feed/doc")
        let titlePattern = try! MXPattern(path: "/title", namespaces: nil)
        doc.entryHandler = { (elm) in
//            var titleString = ""
//            var abstractString = ""
            let title = MXMatch(pattern: titlePattern)
            title.exitHandler = { (elm) in

            }
//            let abstract = try! MXMatch(path: "/abstract")
//            abstract.exitHandler = { (elm) in
//                abstractString = elm.text ?? ""
//            }
//
//            let done = MXMatch.onRootExit({ (elm) in
////                docs.append((titleString, abstractString))
//                numDocs += 1
//            })
//
            return [title]
//            return nil
        }
        doc.exitHandler = { (elm) in
            numDocs += 1
        }
        let title = try! MXMatch(path: "/feed/doc/title")
        title.exitHandler = { (elm) in
//            print(elm.text ?? "no text")
//            if (elm.text?.hasSuffix("t") == true) {
//                elm.stop = true
//            }
        }
        
//
        let parser = MXParser(matches: [doc, title])
//        let parser = MXParser(matches: [])
//        let fileHandle = try! FileHandle(forReadingFrom: Bundle.main.url(forResource: "enwiki-latest-abstract10", withExtension: "xml")!)
//
//
//        while true {
//            let shouldbreak =
//            autoreleasepool { () -> Bool in
//                let data = fileHandle.readData(ofLength: 1024)
//                if (data.isEmpty) {
//                    parser.dataFinished()
//                    fileHandle.closeFile()
//                    return true
//                } else {
//                    parser.parseDataChunk(data)
//                    return false
//                }
//
//            }
//            if shouldbreak {
//                break
//            }
//
//        }
        let data = try! Data(contentsOf: Bundle.main.url(forResource: "enwiki-latest-abstract10", withExtension: "xml")!)

        parser.parseDataChunk(data)
        parser.dataFinished()
        print ("found \(numDocs) docs")
        
    }
    @objc func test() {
        
        let ownerName = try! MXMatch(path: "/opml/head/ns:ownerName", namespaces:["ns":"http://samesimilar.com/xml/test"])
        ownerName.exitHandler = { print($0.text ?? "")}
        
        let body = try! MXMatch(path: "//body")
        body.entryHandler = { (elm) in
            let outline = try! MXMatch(path: "outline", namespaces: nil)
            
            
            outline.entryHandler = { (elm) in
                let text = elm.attributes["text"] ?? "No text"
                let root = MXMatch.onRootExit { (elm) in
                    print (text)
                }

                return [root]
            }
            outline.exitHandler = { (elm) in
                print(elm.attributes["description"] ?? "")
                print("Lower Case Attribute: \(elm.lowercasedAttributes["xmlurl"] ?? "not found")")
            }

            return [outline]
        }
        
//        let urls = try! MXMatch(path: "//@xmlUrl")
        //testns="http://samesimilar.com/xml/test"
        let urls = try! MXMatch(path: "//@ns:xmlUrl", namespaces: ["ns":"http://samesimilar.com/xml/test"])
        urls.attributeHandler = { (elm) in
            print("ATTRIBUTE: \(elm.attrNamespace ?? "") \(elm.attrValue!)")
        }
        
        let parser = MXParser(matches: [ownerName, body, urls])
        
        let data = try! Data(contentsOf: Bundle.main.url(forResource: "subscriptionList", withExtension: "opml")!)
        
        parser.parseDataChunk(data)
        parser.dataFinished()
        
        
    }
    
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
        
        let htmlData = Data()
        
        var links = [String]()
        
        let linkElement = try! MXMatch(path:"//a")
        linkElement.entryHandler = {
            if let url = $0.attributes["href"] {
                links.append(url)
            }
            return nil
        }
        
        let xmlParser = MXHTMLParser(matches: [linkElement])
        xmlParser.parseDataChunk(htmlData)
        xmlParser.dataFinished()
        
        let errorMatch = try! MXMatch(path:"//*")
        errorMatch.errorHandler = { (error, elm) in
            print("An error was encountered: \(error.localizedDescription), \(elm.elementName ?? "Unknown")")
        }
        
        let xmlPxarser = MXParser(matches:[errorMatch])
        
        let nameSpacedMatch = try! MXMatch(path: "/rss/channel/item/georss:point", namespaces: ["georss":"http://www.georss.org/georss"])
        
        let htmlString = "<a>Click href=\"mailto:support@example.com\"here</a> to <b>contact support.</b>"
        let string = MXHTMLToAttributedString().convertHTMLString(htmlString)
        
        return result
       
    }
    
    
    func dictHandler(onExit: @escaping ([String: Any]) -> Void) -> MXStartElementHandler {
        return { (elm) in
            var obj = [String: Any]()
            var currentKey: String! = nil
            
            let key = try! MXMatch(path: "/key")
            key.exitHandler = { (elm) in
                currentKey = elm.text
            }
            
            let real = try! MXMatch(path: "/real")
            real.exitHandler = { (elm) in
                obj[currentKey] = Double(elm.text!)
            }
            
            let integer = try! MXMatch(path: "/integer")
            integer.exitHandler = { (elm) in
                obj[currentKey] = Int(elm.text!)
            }
            
            let tr = try! MXMatch(path: "/true")
            tr.exitHandler = { (elm) in
                obj[currentKey] = true
            }
            
            let fl = try! MXMatch(path: "/false")
            fl.exitHandler = { (elm) in
                obj[currentKey] = false
            }
            
            let date = try! MXMatch(path: "/date")
            date.exitHandler = { (elm) in
                obj[currentKey] = Date.dateFromISOString(string: elm.text!)
            }
            
            let data = try! MXMatch(path: "/data")
            data.exitHandler = { (elm) in
                obj[currentKey] = Data.init(base64Encoded: elm.text!)
            }
            
            let str = try! MXMatch(path: "/string")
            str.exitHandler = { (elm) in
                obj[currentKey] = elm.text
            }
            
            let subDict = try! MXMatch(path: "/dict")
            subDict.entryHandler = self.dictHandler(onExit: {(d) in
                obj[currentKey] = d
            })
            
            let subArray = try! MXMatch(path: "/array")
            subArray.entryHandler = self.arrayHandler(onExit: { (a) in
                obj[currentKey] = a
            })
            
            
            let root = MXMatch.onRootExit({ (elm) in
                onExit(obj)
            })
            
            
            
            return [key, real, integer, tr, fl, date, data, str, subDict, subArray, root]
            
        }
    }
    
    func arrayHandler(onExit: @escaping ([Any]) -> Void) -> MXStartElementHandler {
        return { (elm) in
            var obj = [Any]()
            
            let real = try! MXMatch(path: "/real")
            real.exitHandler = { (elm) in
                obj.append(Double(elm.text!)!)
            }
            
            let integer = try! MXMatch(path: "/integer")
            integer.exitHandler = { (elm) in
                obj.append(Int(elm.text!)!)
            }
            
            let tr = try! MXMatch(path: "/true")
            tr.exitHandler = { (elm) in
               obj.append(true)
            }
            
            let fl = try! MXMatch(path: "/false")
            fl.exitHandler = { (elm) in
                obj.append(false)
            }
            
            let date = try! MXMatch(path: "/date")
            date.exitHandler = { (elm) in
                obj.append(Date.dateFromISOString(string: elm.text!)!)
            }
            
            let data = try! MXMatch(path: "/data")
            data.exitHandler = { (elm) in
                obj.append(Data.init(base64Encoded: elm.text!)!)
            }
            
            let str = try! MXMatch(path: "/string")
            str.exitHandler = { (elm) in
                obj.append(elm.text!)
            }
            
            let subDict = try! MXMatch(path: "/dict")
            subDict.entryHandler = self.dictHandler(onExit: {(d) in
                obj.append(d)
            })
            
            let subArray = try! MXMatch(path: "/array")
            subArray.entryHandler = self.arrayHandler(onExit: { (a) in
                obj.append(a)
            })
            
            let root = MXMatch.onRootExit({ (elm) in
                onExit(obj)
            })
            
            
            
            return [real, integer, tr, fl, date, data, str, subDict, subArray, root]
            
        }
    }
    @objc func plistParser() {
        
        var root: Any!
        
        let dict = try! MXMatch(path: "/plist/dict")
        

        dict.entryHandler = self.dictHandler(onExit: {(subDict) in
            root = subDict
        })
        
        let array = try! MXMatch(path: "/plist/array")
        
        array.entryHandler = self.arrayHandler(onExit: { (subArray) in
            root = subArray
        })
        
        // TODO: root object is single value (e.g. real, integer, string, etc.)
        let parser = MXParser(matches: [dict, array])
        
        let data = try! Data(contentsOf: Bundle.main.url(forResource: "plist-example", withExtension: "xml")!)
        parser.parseDataChunk(data)
        parser.dataFinished()
        
        print(root)
    }
}
