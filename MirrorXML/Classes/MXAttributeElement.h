//
//  MXAttributeElement.h
//  MirrorXML
//
//  Created by Mike Spears on 2018-02-19.
//

#import <Foundation/Foundation.h>

#import "MXElement.h"

@interface MXAttributeElement : MXElement
@property (nonatomic, nonnull) NSString *attrName;
@property (nonatomic, nullable) NSString *attrValue;
@property (nonatomic, nullable) NSString *attrNamespace;
@end
