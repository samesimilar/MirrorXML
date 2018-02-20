//
//  MXElement.m
//  MirrorXML
//
//  Created by Mike Spears on 2014-04-18.
//  Copyright (c) 2014 samesimilar. All rights reserved.
//

#import "MXElement.h"
#import <libxml/tree.h>

@interface MXElement ()

@property (nonatomic) MXElement *parent;

@property (nonatomic, assign) const xmlChar *localName;
@property (nonatomic, assign) const xmlChar *xmlNamespaceURI;

@property (nonatomic, nonnull) NSString * elementName;
@property (nonatomic, nullable) NSString * namespaceURI;
@property (nonatomic, nonnull) NSDictionary<NSString *, NSString *> * attributes;

@property (nonatomic) NSMutableData * textData;
@property (nonatomic) NSString * text;
@end
@implementation MXElement

- (NSString *) elementName {
    if (!_elementName) {
        if (self.localName) {
            self.elementName = [NSString stringWithUTF8String:(const char *)self.localName];
        } else {
            self.elementName = @"";
        }
    }
    return _elementName;
}

- (NSString *) namespaceURI {
    if (!_namespaceURI && self.xmlNamespaceURI) {
        _namespaceURI = [NSString stringWithUTF8String:(const char *)self.xmlNamespaceURI];
    }
    return _namespaceURI;
}

- (void)appendCharacters:(const char *)charactersFound
                  length:(NSInteger)length
{
    if (!_textData)
    {
        _textData = [NSMutableData data];
    }
    [_textData appendBytes:charactersFound length:length];
    _text = nil;
}

- (NSString *) text
{
    if (!_text && _textData) {
        _text = [[NSString alloc] initWithData:_textData
                                      encoding:NSUTF8StringEncoding];
    }
    return _text;
}

- (MXElementNodeType) nodeType
{
    return MXElementNodeTypeElement;
}

@end
