//
//  MXElement.h
//  MirrorXML
//
//  Created by Mike Spears on 2014-04-18.
//  Copyright (c) 2014 samesimilar. All rights reserved.
//

#import <Foundation/Foundation.h>


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

- (instancetype) initWithContext:(nullable id) context;
- (void) reset;

@property (nonatomic, readonly, nullable) NSString * elementName;
@property (nonatomic, readonly, nullable) NSString * namespaceURI;
@property (nonatomic, readonly) NSDictionary<NSString *, NSDictionary<NSString *, NSString *> *> * namespacedAttributes;
@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> * attributes;
@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> * lowercasedAttributes;
@property (nonatomic ,readonly, nullable) NSString * text;
@property (nonatomic, readonly, assign) MXElementNodeType nodeType;
@property (nonatomic, readonly, nullable) MXElement *parent;
@property (nonatomic, nullable) id userInfo;

// if YES will not process handler blocks for this element further up the chain (but will still add it to the current path for all handlers for pattern matching purposes)
// - allows you to override previous handlers
@property (nonatomic, assign) BOOL stop;


@end

NS_ASSUME_NONNULL_END
