//
//  MXElement.h
//  MirrorXML
//
//  Created by Mike Spears on 2014-04-18.
//  Copyright (c) 2014 samesimilar. All rights reserved.
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

/**
 MXElement objects are used to encapsulate properties of the elements parsed by the libxml parser.
 
 You do not create instances of this class. They are passed as parameters to MXMatch callbacks.
 
 @warning In order to reduce processing, these objects are re-used internally, and most property values are not copied from memory controlled by libxml into NSString objects until they are accessed by you. Thus, the property values here are undefined outside of the context where you receive a particular instance of MXElement. So don't keep MXElement objects around - copy/retain the strings that you need.
*/
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
