//
//  MXAttributeElement.m
//  MirrorXML
//
//  Created by Mike Spears on 2018-02-19.
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

#import "MXAttributeElement.h"
#import <libxml/tree.h>

@interface MXElement ()

- (void) reset;

@end

@interface MXAttributeElement()

@property (nonatomic, assign) const xmlChar *xmlAttrName;
@property (nonatomic, assign) const xmlChar *xmlAttrValue;
@property (nonatomic, assign) NSUInteger xmlAttrValueLength;
@property (nonatomic, assign) const xmlChar *xmlAttrNamespace;

@property (nonatomic, nullable) NSString *attrName;
@property (nonatomic, nullable) NSString *attrValue;
@property (nonatomic, nullable) NSString *attrNamespace;

@end

@implementation MXAttributeElement

- (void) reset {
    [super reset];
    
    self.attrName = nil;
    self.attrValue = nil;
    self.attrNamespace = nil;
    self.xmlAttrName = NULL;
    self.xmlAttrValue = NULL;
    self.xmlAttrValueLength = 0;
    self.xmlAttrNamespace = NULL;
}

- (MXElementNodeType) nodeType
{
    return MXElementNodeTypeAttribute;
}

- (NSString *) attrName {
    if (!_attrName) {
        if (_xmlAttrName) {
             _attrName = [[NSString alloc] initWithUTF8String:(const char *)_xmlAttrName];
        } 
    }
    return _attrName;
}

- (NSString *) attrValue {
    if (!_attrValue) {
        if (_xmlAttrValue) {
            _attrValue = [[NSString alloc] initWithBytes:(const void *)_xmlAttrValue
                                                  length:_xmlAttrValueLength
                                                encoding:NSUTF8StringEncoding];
        }
    }
    return _attrValue;
}

- (NSString *) attrNamespace {
    if (!_attrNamespace) {
        if (_xmlAttrNamespace) {
            _attrNamespace = [[NSString alloc] initWithUTF8String:(const char *)_xmlAttrNamespace];
        }
    }
    return _attrNamespace;
}


@end
