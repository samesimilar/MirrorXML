//
//  MXHandlerList.h
//  MirrorXML
//
//  Created by Mike Spears on 2014-04-21.
//  Copyright (c) 2014 samesimilar. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MXElement, MXTextElement, MXParser;

NS_ASSUME_NONNULL_BEGIN

@interface MXMatchList : NSObject

@property (nonatomic, nullable) MXElement * elm;
@property (nonatomic, nullable) NSMutableArray * handlers;
@property (nonatomic, readonly) MXMatchList * parentList;


- (void) reset;
- (void) removeChildren;
- (MXMatchList *) enterElement:(MXElement *) elm;
- (void) exitElement;
- (void) exitElement:(MXElement *) elm;
- (void) streamReset;
- (void) errorRaised:(NSError *) error onElement:(nullable MXElement * ) elm;
- (MXElement *) childElement;
- (MXTextElement *) childTextElement;

@end

NS_ASSUME_NONNULL_END
