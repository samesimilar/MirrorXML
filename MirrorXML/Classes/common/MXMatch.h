//
//  MXHandler.h
//  MirrorXML
//
//  Created by Mike Spears on 2014-04-18.
//  Copyright (c) 2014 samesimilar. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MXPatternStream, MXElement, MXAttributeElement, MXPattern, MXParser, MXMatch;

NS_ASSUME_NONNULL_BEGIN

typedef NSArray<MXMatch *> * _Nullable MXInnerMatches;
typedef MXInnerMatches  (^MXStartElementHandler)(MXElement *);
typedef void            (^MXEndElementHandler)(MXElement *);
typedef void            (^MXTextHandler)(MXElement *);
typedef void            (^MXAttributeHandler)(MXAttributeElement *);
typedef void            (^MXErrorHandler)(NSError *, MXElement *);

@interface MXMatch : NSObject

/**
 A block object that is called when the pattern is matched in the incoming xml document. This is called before any subsequent elements or child elements are matched.
 
 The block may return either 'nil' or an array of MXMatch objects that are used to match elements until the parser exits the current element.
*/
@property (nonatomic, copy) MXStartElementHandler entryHandler;

/**
 A block object that is called when the parser exits the currently matched element. This is called after all child elements and text of the current element are parsed.
*/
@property (nonatomic, copy) MXEndElementHandler exitHandler;

/**
 A block object that is called when the parser encounters a text node in the currently matched element. The complete text will also be passed in the element object that is passed to the exitHandler block.
*/
@property (nonatomic, copy) MXTextHandler textHandler;

/**
 A block object that is called when an attribute pattern is matched. Attributes are also included in the element object that is passed to the entryHandler block.
*/
@property (nonatomic, copy) MXAttributeHandler attributeHandler;

/**
 A block that is called when libxml encounters an error during parsing. This block will only be called if an error is encountered inside an xml element (or child element) matched by this MXMatch object's pattern.
 
 To get a callback that will occur if an error is encountered anywhere in the document, create an MXMatch object with the pattern '//*', and assign a block object to this property.
 
 Note that errors encountered during html parsing (with MXHTMLParser) are often not fatal (for libxml).
*/
@property (nonatomic, copy) MXErrorHandler errorHandler;

/**
 The pattern that was use to construct this MXMatch object. Read only.
*/
@property (nonatomic, readonly) MXPattern * pattern;


/**
 Convenience constructor. Constructs a new MXMatch object with a new MXPattern object using the XPath-style path and namespaces parameters.
 
 Element/attribute names are case-sensitive for xml contexts. They are case-insensitive for html contexts.
 
 Some examples:
 
 /root/child             --> Match 'child' elements that are children of 'root'
 
 /root/child/child       --> Match 'child' elements that are children of 'child' that are children of 'root'
 
 /root/child/@attrName   --> Match 'child' elements (that are children of 'root') that have an attribute named 'attrName'.
 
 The asterisk character is a wildcard, it matches any element. Use it in place of an element name.
 
 //                      --> Path flattener. Use it in place of a '/' character. Matches the path that follows it at any level.
 
 /root/ns:child          --> The child element is specified with a namespace prefix. The 'ns' prefix is mapped to a full namespace URI in the namespaces dictionary parameter.
 
 @param path The path to match. This is a simplified XPath-style path, passed here as an NSString, and parsed by libxml. Complex predicates are not accepted.
 
 @param namespaces A dictionary mapping prefix keys to URI namespace values. The prefix is used to internally identify prefixes in the `path` parameter and doesn't necessarily refer to the arbitrary prefix would be used in the actual xml document being scanned.
 
 @param error Returns an NSError object if the path cannot be parsed for some reason.
 
*/
- (nullable instancetype) initWithPath:(NSString *) path
                            namespaces:(nullable NSDictionary<NSString *, NSString *> *)namespaces
                                 error:(NSError * __nullable * __null_unspecified) error;

/**
 Convenience constructor. Constructs a new MXMatch object with a new MXPattern object using the XPath-style path parameter.
 
 Element/attribute names are case-sensitive for xml contexts. They are case-insensitive for html contexts.
 
 Some examples:
 
 /root/child             --> Match 'child' elements that are children of 'root'
 
 /root/child/child       --> Match 'child' elements that are children of 'child' that are children of 'root'
 
 /root/child/@attrName   --> Match 'child' elements (that are children of 'root') that have an attribute named 'attrName'.
 
 The asterisk character is a wildcard, it matches any element. Use it in place of an element name.
 
 //                      --> Path flattener. Use it in place of a '/' character. Matches the path that follows it at any level.
 
 /root/ns:child          --> The child element is specified with a namespace prefix. The 'ns' prefix is mapped to a full namespace URI in the namespaces dictionary parameter.
 
 @param path The path to match. This is a simplified XPath-style path, passed here as an NSString, and parsed by libxml. Complex predicates are not accepted.
 
 @param error Returns an NSError object if the path cannot be parsed for some reason.
 
*/
- (nullable instancetype) initWithPath:(NSString *) path
                                 error:(NSError * __nullable * __null_unspecified)error;

/**
 Default constructor. Constructs a new MXMatch object with an MXPattern object.
 
 @param pattern The MXPattern object.
*/
- (instancetype) initWithPattern:(nullable MXPattern *) pattern;

/**
 Creates and returns a special MXMatch object that matches the end of the current element. Use this during parsing to create an exit callback that is called when the parser exits the current element.
 
 Normally you would use this method inside an 'entryHandler' object (with a block that captures variables from the entryHandler context) to create an MXMatch object that is returned by your entryHandler block. See the readme for examples.
 
 @param exitHandler The block to call when the current element is finished. It is called only once.
*/
+ (instancetype) onRootExit: (MXEndElementHandler) exitHandler;

@end

NS_ASSUME_NONNULL_END
