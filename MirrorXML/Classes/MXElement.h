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
    MXelementNodeTypeProcessingInstruction
} ;

@interface MXElement : NSObject
@property (nonatomic) NSString * elementName;
@property (nonatomic) NSString * namespaceURI;
@property (nonatomic) NSDictionary * attributes;
@property (nonatomic ,readonly) NSString * text;
@property (nonatomic, readonly, assign) MXElementNodeType nodeType;
@property (nonatomic) id userInfo;

// if YES will not process handler blocks for this element further up the chain (but will still add it to the current path for all handlers for pattern matching purposes)
// - allows you to override previous handlers
@property (nonatomic, assign) BOOL stop;

- (void)appendCharacters:(const char *)charactersFound
                  length:(NSInteger)length;

@end
