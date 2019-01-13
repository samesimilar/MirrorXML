//
//  MXAttributeElement.m
//  MirrorXML
//
//  Created by Mike Spears on 2018-02-19.
//

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
