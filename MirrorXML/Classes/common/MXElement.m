//
//  MXElement.m
//  MirrorXML
//
//  Created by Mike Spears on 2014-04-18.
//  Copyright (c) 2014 samesimilar. All rights reserved.
//

#import "MXElement.h"
#import <libxml/tree.h>


static NSDictionary * namespacedDictionaryForAttributes(int nb_attributes, const xmlChar ** attributes)
{
    if (nb_attributes == 0) {
        return @{@"": @{}};
    }
    NSMutableDictionary * result = [NSMutableDictionary new];
    NSMutableDictionary * noNamespaceAttributes = [NSMutableDictionary new];
    result[@""] = noNamespaceAttributes;
    NSInteger index = 0;
    for (NSInteger i = 0; i < nb_attributes; i++, index += 5)
    {
        //[localname/prefix/URI/value/en]
        // TODO: should have separate entry in dict for each localname/URI *combination* (localnames may overlap within different URIs)
        if (attributes[index + 3] != 0)
        {
            
            NSString * localName = [[NSString alloc] initWithUTF8String:(const char *)(attributes[index])];// lowercaseString];
            
//            NSString * prefix = attributes[index + 1] != NULL ? [[NSString alloc] initWithUTF8String:(const char *)(attributes[index + 1])] : @"-";
            
            NSString * URI = attributes[index + 2] != NULL ? [[NSString alloc] initWithUTF8String:(const char *)(attributes[index + 2])] : nil;
            
//            NSLog(@"ATTRIBUTE INFO: prefix[%@], URI[%@]", prefix, URI);
            
            NSUInteger valueLength = attributes[index + 4] - attributes[index + 3];
            
            NSString * value = [[NSString alloc] initWithBytes:(const void *)(attributes[index + 3])
                                                        length: valueLength
                                                      encoding:NSUTF8StringEncoding];
            if (URI == nil) {
                noNamespaceAttributes[localName] = value;
            } else {
                NSMutableDictionary * uriAttributes = result[URI];
                if (uriAttributes == nil) {
                    uriAttributes = [NSMutableDictionary new];
                    result[URI] = uriAttributes;
                }
                uriAttributes[localName] = value;
            }
            
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
            value = [[NSString alloc] initWithUTF8String:(const char *)(*attr)];
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
@property (nonatomic, assign) BOOL attributesExpired;

// used to mark instances of this class invalid once the context has been deallocated
// since the above resources are owned by the libxml context
@property (nonatomic, weak, nullable) id livingParserContext;

@property (nonatomic) NSString * elementName;
@property (nonatomic, nullable) NSString * namespaceURI;
@property (nonatomic) NSDictionary<NSString *, NSDictionary<NSString *, NSString *> *> * namespacedAttributes;
@property (nonatomic) NSDictionary<NSString *, NSString *> * attributes;
@property (nonatomic) NSDictionary<NSString *, NSString *> * lowercasedAttributes;

@property (nonatomic) NSMutableData * textData;
@property (nonatomic) NSString * text;

@end
@implementation MXElement

- (instancetype) initWithContext:(id) context {
    if (self = [super init]) {
        self.livingParserContext = context;
        self.attributesExpired = NO;
    }
    return self;
}

- (instancetype) init {
    return [self initWithContext:nil];
}
- (void) reset {
    self.parent = nil;
    self.xmlLocalname = NULL;
    self.xmlNamespaceURI = NULL;
    self.xmlNb_attributes = 0;
    self.xmlAttributes = NULL;
    self.attributesExpired = NO;
    self.elementName = nil;
    self.namespaceURI = nil;
    self.namespacedAttributes = nil;
    self.attributes = nil;
    self.lowercasedAttributes = nil;
    self.textData = nil;
    self.text = nil;
}

- (NSString *) elementName {
    if (!_elementName) {
        NSAssert(_livingParserContext,
                 @"MirroXML: MXElement instances are invalid after the parent MXParser context has been deallocated.");
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
                 @"MirroXML: MXElement instances are invalid after the parent MXParser context has been deallocated.");
        _namespaceURI = [NSString stringWithUTF8String:(const char *)self.xmlNamespaceURI];
    }
    return _namespaceURI;
}

- (void) buildAttributesDictionary {
    NSAssert(!_attributesExpired, @"MirroXML: The element attributes dictionary can only be first accessed during the entryHandler & attributeHandler phase of matching, since libxml may overwrite certain values in memory while scanning following elements.");
    if (_xmlAttributes) {
        _namespacedAttributes = namespacedDictionaryForAttributes(_xmlNb_attributes, _xmlAttributes);
        _attributes = _namespacedAttributes[@""];
    } else if (_htmlAttributes) {
        _attributes = dictionaryForHTMLAttributes(_htmlAttributes);
        // html attributes are already converted to lowercase
        _lowercasedAttributes = _attributes;
        _namespacedAttributes = @{@"" : _attributes};
        
    } else {
        _attributes = [NSDictionary new];
        _lowercasedAttributes = _attributes;
        _namespacedAttributes = @{@"" : _attributes};
    }
}

- (NSDictionary<NSString *, NSDictionary<NSString *, NSString *> *> *) namespacedAttributes {
    if (!_namespacedAttributes) {
        NSAssert(_livingParserContext,
                 @"MirroXML: MXElement instances are invalid after the parent MXParser context has been deallocated.");
        [self buildAttributesDictionary];
    }
    return _namespacedAttributes;
}

- (NSDictionary<NSString *, NSString *> *) attributes {
    if (!_attributes) {
        NSAssert(_livingParserContext,
                 @"MirroXML: MXElement instances are invalid after the parent MXParser context has been deallocated.");
        [self buildAttributesDictionary];
    }
    return _attributes;
}

- (NSDictionary<NSString *, NSString *> *) lowercasedAttributesForNamespace:(nullable NSString *) namespace {
    NSDictionary<NSString *, NSString*> * dictionaryToProcess;
    if (namespace == nil) {
        dictionaryToProcess = self.attributes;
    } else {
        dictionaryToProcess = self.namespacedAttributes[namespace];
        if (!dictionaryToProcess) return [NSDictionary new];
    }
    
    NSMutableDictionary<NSString *, NSString *> * result = [NSMutableDictionary new];
    [dictionaryToProcess enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        result[[key lowercaseString]] = obj;
    }];
    return result;
}

- (NSDictionary<NSString *, NSString *> *) lowercasedAttributes {
    if (!_lowercasedAttributes) {
        _lowercasedAttributes = [self lowercasedAttributesForNamespace:nil];
    }
    return _lowercasedAttributes;
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
