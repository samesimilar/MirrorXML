//
//  MXHandlerList.h
//  MirrorXML
//
//  Created by Mike Spears on 2014-04-21.
//  Copyright (c) 2014 samesimilar. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MXElement, MXParser;

NS_ASSUME_NONNULL_BEGIN

@interface MXHandlerList : NSObject

@property (nonatomic, nullable) MXElement * elm;
@property (nonatomic, nullable) NSArray * handlers;

- (MXHandlerList *) enterElement:(MXElement *) elm;
- (nullable MXHandlerList *) exitElement;
- (void) streamReset;
- (void) errorRaised:(NSError *) error onElement:(nullable MXElement * ) elm;


@end

NS_ASSUME_NONNULL_END
