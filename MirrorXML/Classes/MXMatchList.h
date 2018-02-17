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

@interface MXMatchList : NSObject

@property (nonatomic, nullable) MXElement * elm;
@property (nonatomic, nullable) NSArray * handlers;

- (MXMatchList *) enterElement:(MXElement *) elm;
- (nullable MXMatchList *) exitElement;
- (void) streamReset;
- (void) errorRaised:(NSError *) error onElement:(nullable MXElement * ) elm;


@end

NS_ASSUME_NONNULL_END
