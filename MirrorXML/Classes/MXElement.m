//
//  MXElement.m
//  MirrorXML
//
//  Created by Mike Spears on 2014-04-18.
//  Copyright (c) 2014 samesimilar. All rights reserved.
//

#import "MXElement.h"
#import <libxml/tree.h>


static NSDictionary * dictionaryForAttributes(int nb_attributes, const xmlChar ** attributes)
{
    NSMutableDictionary * result = [NSMutableDictionary new];
    NSInteger index = 0;
    for (NSInteger i = 0; i < nb_attributes; i++, index += 5)
    {
        //[localname/prefix/URI/value/en]
        // TODO: should have separate entry in dict for each localname/URI *combination* (localnames may overlap within different URIs)
        if (attributes[index + 3] != 0)
        {
            
            NSString * key = [[NSString alloc] initWithUTF8String:(const char *)(attributes[index])];// lowercaseString];
            
            NSUInteger valueLength = attributes[index + 4] - attributes[index + 3];
            
            NSString * value = [[NSString alloc] initWithBytes:(const void *)(attributes[index + 3])
                                                        length: valueLength
                                                      encoding:NSUTF8StringEncoding];
            
            result[key] = value;
            
        }
    }
    return result;
}

static NSDictionary * dictionaryForHTMLAttributes(const xmlChar ** attributes)
{
    if (attributes == NULL) {
        return @{};
    }
    NSMutableDictionary * result = [NSMutableDictionary new];
    
    const xmlChar ** attr = attributes;
    
    while (*attr)
    {
        NSString * key = [[[NSString alloc] initWithUTF8String:(const char *)(*attr)] lowercaseString];
        attr++;
        NSString * value = nil;
        if (*attr) {
            value = [[[NSString alloc] initWithUTF8String:(const char *)(*attr)] lowercaseString];
        }
        
        attr++;
        if (key && value) {
            result[key] = value;
        }
        
    }
    
    
    return result;
}


@interface MXElement ()

@property (nonatomic) MXElement *parent;

@property (nonatomic, assign) const xmlChar *xmlLocalname;
@property (nonatomic, assign) const xmlChar *xmlNamespaceURI;
@property (nonatomic, assign) int xmlNb_attributes;
@property (nonatomic, assign) const xmlChar **xmlAttributes;
@property (nonatomic, assign) const xmlChar **htmlAttributes;

// used to mark instances of this class invalid once the context has been deallocated
// since the above resources are owned by the libxml context
@property (nonatomic, weak, nullable) id livingParserContext;

@property (nonatomic, nonnull) NSString * elementName;
@property (nonatomic, nullable) NSString * namespaceURI;
@property (nonatomic, nonnull) NSDictionary<NSString *, NSString *> * attributes;

@property (nonatomic) NSMutableData * textData;
@property (nonatomic) NSString * text;
@end
@implementation MXElement

- (instancetype) initWithContext:(id) context {
    if (self = [super init]) {
        self.livingParserContext = context;
    }
    return self;
}

- (NSString *) elementName {
    if (!_elementName) {
        NSAssert(_livingParserContext,
                 @"MXElement instances are invalid after the parent MXParser context has been deallocated.");
        if (_xmlLocalname) {
            self.elementName = [NSString stringWithUTF8String:(const char *)_xmlLocalname];
        } else {
            self.elementName = @"";
        }
    }
    return _elementName;
}

- (NSString *) namespaceURI {
    if (!_namespaceURI && self.xmlNamespaceURI) {
        NSAssert(_livingParserContext,
                 @"MXElement instances are invalid after the parent MXParser context has been deallocated.");
        _namespaceURI = [NSString stringWithUTF8String:(const char *)self.xmlNamespaceURI];
    }
    return _namespaceURI;
}

- (void) buildAttributesDictionary {
    if (_xmlAttributes) {
        _attributes = dictionaryForAttributes(_xmlNb_attributes, _xmlAttributes);
    } else if (_htmlAttributes) {
        _attributes = dictionaryForHTMLAttributes(_htmlAttributes);
    } else {
        _attributes = [NSDictionary new];
    }
}

- (NSDictionary<NSString *, NSString *> *) attributes {
    if (!_attributes) {
        NSAssert(_livingParserContext,
                 @"MXElement instances are invalid after the parent MXParser context has been deallocated.");
        [self buildAttributesDictionary];
    }
    return _attributes;
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
