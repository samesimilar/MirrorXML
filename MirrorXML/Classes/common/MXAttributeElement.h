//
//  MXAttributeElement.h
//  MirrorXML
//
//  Created by Mike Spears on 2018-02-19.
//

#import <Foundation/Foundation.h>

#import "MXElement.h"

/**
 This subclass of MXElement represents the data of a single attribute. Only the attrName, attrValue, attrNamespace property values are defined.
*/
@interface MXAttributeElement : MXElement
/**
 The case-sensitive attribute name, not including the namespace or prefix.
*/
@property (nonatomic, nonnull, readonly) NSString *attrName;
/**
 The attribute value.
*/
@property (nonatomic, nullable, readonly) NSString *attrValue;
/**
 The case-sensitive namepace URI.
*/
@property (nonatomic, nullable, readonly) NSString *attrNamespace;
@end
