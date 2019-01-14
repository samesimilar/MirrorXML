//
//  ReadPLIST.swift
//  MirrorXML_Example
//
//  Created by Mike Spears on 2019-01-14.
//  Copyright © 2019 samesimilar@gmail.com. All rights reserved.
//

import Foundation
import MirrorXML

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
