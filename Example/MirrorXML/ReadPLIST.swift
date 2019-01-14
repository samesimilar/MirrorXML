//
//  ReadPLIST.swift
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

/**
 This is just an illustrative example of parsing a PLIST file - not something to use in a real app.
 It shows a method of parsing an arbitrarily deep xml file using MirrorXML.
*/
class ReadPLIST : NSObject {
    private func dictHandler(onExit: @escaping ([String: Any]) -> Void) -> MXStartElementHandler {
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
    
    private func arrayHandler(onExit: @escaping ([Any]) -> Void) -> MXStartElementHandler {
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
    @objc func parse() -> Any {
        
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
        return root
    }
}
