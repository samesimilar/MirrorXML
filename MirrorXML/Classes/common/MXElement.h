//
//  MXElement.h
//  MirrorXML
//
//  Created by Mike Spears on 2014-04-18.
//  Copyright (c) 2014 samesimilar. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 The type of xml or html element represented by an MXElement object.
*/
typedef NS_ENUM(NSInteger, MXElementNodeType) {
    MXElementNodeTypeElement,
    MXElementNodeTypeAttribute,
    MXElementNodeTypeText,
    MXElementNodeTypeCData,
    MXElementNodeTypeComment,
    MXElementNodeTypeProcessingInstruction,
} ;

NS_ASSUME_NONNULL_BEGIN

@interface MXElement : NSObject

/**
 The name of this element. The case of this string is the same as the case found in the document (it is not lowercased). Read only.
 
 @warning This property is only valid for reading while the associated MXParser/MXTHMLParser object is parsing the associated element (i.e. between the entryHandler and exitHandler callbacks, inclusivly). Best practice is to read the property during parsing and retain/copy the NSString if you need it later. Don't keep MXElement objects around for later use.
*/
@property (nonatomic, readonly, nullable) NSString * elementName;

/**
 The full namespace URI of this element (not the prefix). The case of this string is the same as the case found in the document (it is not lowercased). Read only.
 
 @warning This property is only valid for reading while the associated MXParser/MXTHMLParser object is parsing the associated element (i.e. between the entryHandler and exitHandler callbacks, inclusivly). Best practice is to read the property during parsing and retain/copy the NSString if you need it later. Don't keep MXElement objects around for later use.
 */
@property (nonatomic, readonly, nullable) NSString * namespaceURI;

/**
 The attributes for this element. It is a dictionary of namepspace URI keys mapped to dictionaries of attribute names & values. The dictionary of attributes without a namespace can be accessed with an empty string as the key. Read only.
 
 The attribute and namespace keys are in the same case as in the document.
 
 @warning Because of the way that libxml manages memory, this property is only valid inside the 'enterElement' block callback for the matched element. Incorrect access to this property may cause an assertion failure.
 
 @see attributes
 @see lowercasedAttributes
 @see lowercasedAttributesForNamespace
 */
@property (nonatomic, readonly) NSDictionary<NSString *, NSDictionary<NSString *, NSString *> *> * namespacedAttributes;

/**
 The attributes for this element (that don't have a namespace). It is a dictionary of attribute names & values. Read only.
 
 The attribute keys are in the same case as in the document.
 
 @warning Because of the way that libxml manages memory, this property is only valid inside the 'enterElement' block callback for the matched element. Incorrect access to this property may cause an assertion failure.
 
 @see namespacedAttributes
 @see lowercasedAttributes
 @see lowercasedAttributesForNamespace
 */
@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> * attributes;

/**
 The attributes for this element (that don't have a namespace). It is a dictionary of attribute names & values. Read only.
 
 The attribute keys are normalized to lowercase using NSString's non-localized 'lowercaseString' method. If there are multiple keys in the same element that map to the same lowercased string, only one of the associated values will be kept.
 
 @warning Because of the way that libxml manages memory, this property is only valid inside the 'enterElement' block callback for the matched element. Incorrect access to this property may cause an assertion failure.
 
 @see namespacedAttributes
 @see attributes
 @see lowercasedAttributesForNamespace
*/
@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> * lowercasedAttributes;

/**
 The text found inside this element. (Does not include text found inside children of this element.)  Read only.
 
 This property will not have a value until exitHandler is called.
 
 @warning This property is only valid for reading while the associated MXParser/MXTHMLParser object is parsing the associated element (i.e. between the entryHandler and exitHandler callbacks, inclusivly). Best practice is to read the property during parsing and retain/copy the NSString if you need it later. Don't keep MXElement objects around for later use.
*/
@property (nonatomic ,readonly, nullable) NSString * text;

/**
 The type of element node represented by this object. Read only.
 
  @warning This property is only valid for reading while the associated MXParser/MXTHMLParser object is parsing the associated element (i.e. between the entryHandler and exitHandler callbacks, inclusivly). Best practice is to read the property during parsing and retain/copy the value if you need it later. Don't keep MXElement objects around for later use.
*/
@property (nonatomic, readonly, assign) MXElementNodeType nodeType;

/**
 The MXElement object that is the immediate parent of this object. Read only.
 
  @warning This property is only valid for reading while the associated MXParser/MXTHMLParser object is parsing the associated element (i.e. between the entryHandler and exitHandler callbacks, inclusivly). Don't keep MXElement objects around for later use.
*/
@property (nonatomic, readonly, nullable) MXElement *parent;

/**
 You can assign a contextual object to this element in case you need to access it later. This will be reset after the current element is exited during parsing.
 
  @warning This property is only valid for reading while the associated MXParser/MXTHMLParser object is parsing the associated element (i.e. between the entryHandler and exitHandler callbacks, inclusivly).
*/
@property (nonatomic, nullable) id userInfo;

/**
// if YES will not process handler blocks for this element further up the chain (but will still add it to the current path for all handlers for pattern matching purposes)
// - allows you to override previous handlers
*/
@property (nonatomic, assign) BOOL stop;

/**
 Case-insensitive attributes for this element.
 
 @warning Because of the way that libxml manages memory, this method should only be called inside the 'enterElement' block callback for the matched element. Incorrect access to this property may cause an assertion failure.
 
 @param namespace The namespace of the attributes to include in the dictionary. Case-sensitive.
 
 @return A dictionary of lowercased attribute keys and (non-lowercased) values.  The attribute keys are normalized to lowercase using NSString's non-localized 'lowercaseString' method. If there are multiple keys in the same element that map to the same lowercased string, only one of the associated values will be kept.
 
 @see namespacedAttributes
 @see attributes
 @see lowercasedAttributes
*/
- (NSDictionary<NSString *, NSString *> *) lowercasedAttributesForNamespace:(nullable NSString *) namespace;

@end

NS_ASSUME_NONNULL_END