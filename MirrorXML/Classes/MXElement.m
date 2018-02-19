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

@property (nonatomic) NSString *privateElementName;
@property (nonatomic) NSString *privateNamespaceURI;

@property (nonatomic, assign) const xmlChar *localName;
@property (nonatomic, assign) const xmlChar *xmlNamespaceURI;

//@property (nonatomic, nonnull) NSString * elementName;
//@property (nonatomic, nullable) NSString * namespaceURI;
@property (nonatomic, nonnull) NSDictionary<NSString *, NSString *> * attributes;

@property (nonatomic) NSMutableData * textData;
@property (nonatomic) NSString * text;
@end
@implementation MXElement

- (NSString *) elementName {
    if (!self.privateElementName) {
        if (self.localName) {
            self.privateElementName = [NSString stringWithUTF8String:(const char *)self.localName];
        } else {
            self.privateElementName = @"";
        }
    }
    return self.privateElementName;
}

- (NSString *) namespaceURI {
    if (!self.privateNamespaceURI && self.xmlNamespaceURI) {
        self.privateNamespaceURI = [NSString stringWithUTF8String:(const char *)self.xmlNamespaceURI];
    }
    return self.privateNamespaceURI;
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
