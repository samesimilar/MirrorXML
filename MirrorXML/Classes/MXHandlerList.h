//
//  MXHandlerList.h
//  MirrorXML
//
//  Created by Mike Spears on 2014-04-21.
//  Copyright (c) 2014 samesimilar. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MXElement, MXParser;

@interface MXHandlerList : NSObject
- (MXHandlerList *) enterElement:(MXElement *) elm;
- (MXHandlerList *) exitElement;
- (void) streamReset;
- (void) errorRaised:(NSError *) error onElement:(MXElement *) elm;
//- (void)setObject:(id)object forKeyedSubscript:(id < NSCopying >)aKey;
//- (id)objectForKeyedSubscript:(id)key;


@property (nonatomic) MXElement * elm;
@property (nonatomic) NSArray * handlers;

@end
