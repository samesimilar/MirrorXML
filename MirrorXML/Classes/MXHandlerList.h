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

@property (nonatomic) MXElement * _Nullable elm;
@property (nonatomic) NSArray * _Nullable handlers;

- (MXHandlerList *) enterElement:(MXElement *) elm;
- (MXHandlerList * _Nullable) exitElement;
- (void) streamReset;
- (void) errorRaised:(NSError *) error onElement:(MXElement * _Nullable) elm;


@end

NS_ASSUME_NONNULL_END
