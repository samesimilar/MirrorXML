# MirrorXML

MirrorXML is a wrapper for libxml2's SAX (push) xml and html parsers. It's also a wrapper for libxml2's streamable XPath pattern matching functionality.

But those two things don't quite describe how these features work together in MirrorXML to make event-driven xml parsing easier. 

Let's put it another way: MirrorXML is a block-based, event-driven, API for parsing xml (and basic html).

MirrorXML doesn't attempt to magically turn XML into Swift model objects, rather, it puts you in control while helping you create more easily maintainable, explicit, and well-strucutred code. 

And it also comes with a neat little customizeable *html to NSAttributedString* API.

## Example

To run the example iOS project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

MirrorXML is written in Objective-C. It can be used in Swift and Objective-C projects.

MirrorXML is compatible with iOS 9.0+ and macOS 10.11+ targets.

## Installation

MirrorXML is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'MirrorXML'
```

## I'm excited to start parsing XML data! How do I use this thing?

Here's a basic example. Let's say we want to get the titles of all the items in an RSS document:

```Swift
var titles = [String]() // array to store the titles

// Create an MXMatch object with the XML path we want.
let titleMatch = try! MXMatch(path: "/rss/channel/item/title")
// Create a block that will be called at the end of every title element.
titleMatch.exitHandler = {(elm) in
    if let text = elm.text {
        titles.append(text)
    }    
}

// Give the MXMatch object to a parser instance and parse the data.
let xmlParser = MXParser(matches: [titleMatch])
xmlParser.parseDataChunk(xmlData)
xmlParser.dataFinished()
```
After parsing is finished, the `titles` array will contain all the titles found by the `MXMatch` object.

`MXMatch` objects have different callback properties that can be assigned blocks. These blocks are called at appropriate points while the parser is reading the xml data.

When a block is called at the beginning of an xml element, it can return temporary `MXMatch` objects that are used to parse the data within the current element. Since blocks are closures, they will retain references to any new objects you create in the same context. 

For example, if we want to decode objects with several different properties that represent RSS items, we could do the following: 

```Swift
var items = [RSSItem]() // An array to store our RSS items

// Create an MXMatch object with the XML path we want.
let itemMatch = try! MXMatch(path: "/rss/channel/item")

// Create a block that will be called at the beginning of every item element.
itemMatch.entryHandler = {(elm) in
    //create a new instance of the RSSItem class and add it to the array
    var thisRSSItem = RSSItem()
    items.append(thisRSSItem)
    
    // Create a temporary MXMatch object with a path that matches title elements.
    // Note that the path is relative to the parent 'item' element.
    let titleMatch = try! MXMatch(path: "/title")
    titleMatch.exitHandler = { (elm) in        
        thisRSSItem.title = elm.text
    }
    // Similar idea for link elements.
    let linkMatch = try! MXMatch(path: "/link")
    titleMatch.exitHandler = { (elm) in
        thisRSSItem.link = elm.text
    }
    // Return the temporary MXMatch objects. They will only apply to the current 'item' element.
    return [titleMatch, linkMatch]
}

// Give the MXMatch object to a parser instance and parse the data.
let xmlParser = MXParser(matches: [itemMatch])
xmlParser.parseDataChunk(xmlData)
xmlParser.dataFinished()
```
The common way to write an event-driven (push) xml parser (without using *MirrorXML*) would be to write a couple functions. One function would be called every time a new element begins, and one function would be called everytime the element ends. (This is how `NSXMLParser and NSXMLParserDelegate` work.)

Since these functions are called for every element, at every level of the xml document structure, they won't naturally be aware of the context they are called in. Thus you have to keep track of lots of states, like `isInsideChannel` or `isInsideItem` or `currentRSSItem`. It can get messy since code that manages different types of data items is mixed together.

*MirrorXML* simplifies everything becuase your code structure mirrors the structure of the XML document, and your callbacks are only activated for elements that they are interested in. As you can see above, all the code you need to build one of these theoretical RSSItem objects is kept together exclusively in one place. And since we are using blocks, they implicitly keep references to their context, so we don't need some global variable like `currentRSSitem.`

### XPath-style Patterns

The previous two examples use simple paths to match elements at particular places in the xml document. There are a few more advanced tricks you can do: 

`/root/item             --> Match 'item' elements that are children of 'root'`

`/root/item/title       --> Match 'title' elements that are children of 'item' that are children of 'root'`

`/root/item|/root/otheritem --> 'OR operator: Match either item or otheritem elements that are children of 'root' `

`/root/item/@attrName   --> Match 'item' elements (that are children of 'root') that have an attribute named 'attrName'.`

`/root/*                 --> Match every element that is a child of root.`

`/root//item            --> Match 'item' elements that are at every level below root.`
`/root//*                --> Match every element at every level below root.`
`//*                     --> Match every element in the document. `

`/root/ns:item          --> The item element is specified with a namespace prefix. The 'ns' prefix is mapped to a full namespace URI in the namespaces dictionary parameter passed to the MXMatch object.`

If you are familar with XPath syntax and symantics then this will look familar, but be aware that more advanced aspects of XPath syntax (like fancy predicates) are not supported. This is because these paths must be 'streamable', i.e. we are evaluating these paths 'as we go'. 

Here's an html example. Let's say we wanted to get all the links in some html data:

```Swift
var links = [String]()

// Match every 'a' element.
let linkElement = try! MXMatch(path:"//a")
linkElement.entryHandler = {
    // Please note that attributes are only available in 'entryHandler' blocks.
    if let url = $0.attributes["href"] {
        links.append(url)
    }
    return nil
}

let htmlParser = MXHTMLParser(matches: [linkElement])
htmlParser.parseDataChunk(htmlData)
htmlParser.dataFinished()
```
### Namespaces

There is a more advanced initializer for MXMatch that can handle namespaces:

```Swift
let nameSpacedMatch = try! MXMatch(path: "/rss/channel/item/georss:point", namespaces: ["georss":"http://www.georss.org/georss"])
```
The `namespaces` parameter takes a dictionary of prefix/URI pairs.

Namespaced attributes can be retrieved via MXElement's `namespacedAttributes` property inside an entryHandler block.


### Error Handling

Parsing errors that are reported by libxml are passed through the MirrorXML API using callback blocks in a similar way to element 'begin' and 'end' events. You assign a block to the `errorHandler` property of `MXMatch` that gets called any time there is an error encountered in any element that matches the `MXMatch` object's pattern. 

For example, to create an error handler that is called if an error is encountered on any element:

```Swift
let errorMatch = try! MXMatch(path:"//*")
errorMatch.errorHandler = { (error, elm) in
    print("An error was encountered: \(error.localizedDescription), \(elm.elementName ?? "Unknown")")
}

// assuming itemMatch and otherItemMatch were previously declared
let xmlParser = MXParser(matches:[errorMatch, itemMatch, otherItemMatch])
// then parseDataChunk etc.
```

### Parsing Large Documents

You can call `parseDataChunk:` multiple times to parse a large document incrementally. For example, you can start parsing a large document while it is still downloading. 

I've made some efforts to keep memory usage constant within MirrorXML during xml parsing, but you can wrap `parseDataChunk:` in an autoreleasepool block if you see lots of temporary objects building up during multiple calls.

### Converting HTML to NSAttributedString

MirrorXML also includes a class called `MXHTMLToAttributedString`. You can give it snippets of html or complete html documents to convert. It's built on top of `MXHTMLParser`.

The advantage of this over NSAttributedString's html->string conversion method is that:

1. You can customize the styling during parsing using a delegate.

2. You can use this on any thread.

3. It seems to be faster (don't call me or anything if it's not).

It only handles basic 'Markdown-style' html tags, links and images. It doesn't handle scripts or stylesheets or anything fancy like that.

Assign an object to the `MXHTMLToAttributedStringDelegate` delegate property to customize the font and paragraph attributes of the resulting text.

An instance of `MXHTMLToAttributedStringDelegateDefault`, which has many customizeable properties, is assigned to the delegate property by default.

libxml's html parser is not strict, so any errors that are encountered are not necessarily fatal. After you convert a string you can check the converter's `errors` property for any errors that were reported during parsing.

It doesn't necessarily require the input to be a full 'html' structured document with stuff like 'head' and 'body' - so you can parse a simple string with a few tags into an attributed string, e.g. `<a>Click href="mailto:support@example.com"here</a> to <b>contact support.</b>` (Note: if you want links to be active inside something like a UILabel, make sure to enable user interaction with the UILabel.)

If image tags are encountered: a placeholder is inserted, and you can replace that with the required image later using `+insertImage:withInfo:toString`.

Example: 

```Swift
let htmlString = "<a>Click href=\"mailto:support@example.com\"here</a> to <b>contact support.</b>"
let string = MXHTMLToAttributedString().convertHTMLString(htmlString)
```

This is a bit experimental and is not guaranteed to produce text like a real browser would. It's best to use on data sets that you have some control over rather than arbitrary data from the web. If you need something more robust it's better to use a web view.

### Thread Safety

You can use MXParser, MXHTMLParser, MXMatch, MXPattern, and MXHTMLToAttributedString on any thread, but don't access the same instance from more than one thread. 

A common scenario would be to use MXHTMLToAttributedString on a background thread and then pass the resulting AttributedString back to the main thread to show in a text view or label. Another common scenario would be to parse xml data into your model object on a background thread.

### Style

MirrorXML works with highly hierarchical callback code built using lots of blocks and layers, but it also works with very flat code with only a few blocks - something more like a standard NSXMLParserDelegate-style deal. It's up to you!

### Further Reading

Check out the included example project to see some more advanced ways to use MirrorXML. I'd also recommend looking at the included unit tests, and maybe the implementation of the MXHTMLToAttributedString class.

## Author

Mike Spears,  samesimilar@gmail.com

## License

MirrorXML is available under the MIT license. See the LICENSE file for more info.
