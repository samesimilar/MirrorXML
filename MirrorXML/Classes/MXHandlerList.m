//
//  MXHandlerList.m
//  MirrorXML
//
//  Created by Mike Spears on 2014-04-21.
//  Copyright (c) 2014 samesimilar. All rights reserved.
//

#import "MXHandlerList.h"
#import "MXPattern.h"

#import "MXMatch.h"
#import "MXElement.h"

@interface MXHandlerList()

@property (nonatomic) MXHandlerList * parentList;


@end
@implementation MXHandlerList

- (id) init
{
    self = [super init];
    if (self){
//        self.handlers = [NSMutableArray new];

    }
    return self;
}

- (void)setObject:(id)object forKeyedSubscript:(id < NSCopying >)aKey
{
    MXMatch * newHandler;
    
    if ([(id)aKey isKindOfClass:[MXPattern class]]) {
        newHandler = [MXMatch handlerWithPattern:[(MXPattern *) aKey copy] handlerBlocks:object];
    } else {
        newHandler = [MXMatch handlerWithPatternString:[(NSString *)aKey copy] namespaces:nil handlerBlocks:object];
    }
    
    self.handlers = _handlers ? [_handlers arrayByAddingObject:newHandler] : @[newHandler];
    
    
}

- (id)objectForKeyedSubscript:(id)key
{
    NSString * str = [key isKindOfClass:[MXPattern class]] ? [(MXPattern *)key patternString] : key;
    

    for (MXMatch * h in _handlers)
    {
        if ([h.pattern.patternString isEqualToString:str]) {
            return [h handlerBlockDict];
        }
        
    }
    return nil;
}


- (void) enterElementWithElement:(MXElement *) elm childList:(MXHandlerList *) cl
{
    for (MXMatch * h in _handlers) {
        NSArray * newHandlers = [h enterElement:elm];
        if (newHandlers) {
            cl.handlers = [newHandlers arrayByAddingObjectsFromArray:cl.handlers];
            
        }

    }
    
    if (_parentList) {
        [_parentList enterElementWithElement:elm childList:cl];
    }
}

- (MXHandlerList *) enterElement:(MXElement *) elm {
    
    MXHandlerList * childList = [[MXHandlerList alloc] init];
    childList.parentList = self;
    childList.elm = elm;
    
    
    
    [self enterElementWithElement:elm childList:childList];
    
    [childList streamReset];
    
    return childList;
}

- (void) errorRaised:(NSError *) error onElement:(MXElement *) elm inParser:(MXParser *) parser
{
    for (MXMatch * h in _handlers) {
        [h errorRaised:error onElement:elm inParser:parser];
    }
    if (_parentList) {
        [_parentList errorRaised:error onElement:elm inParser:parser];
    }
}
- (void) exitElement:(MXElement *) elm
{
    for (MXMatch * h in _handlers) {
        [h exitElement:elm];
    }
    
    if (_parentList) {
        [_parentList exitElement:elm];
    }
}

- (MXHandlerList *) exitElement
{
    _elm.stop = NO;
    [self exitElement:_elm];
    
    return _parentList;
    
}


- (void) streamReset
{
    for (MXMatch * h in _handlers)
    {
        [h streamReset];
    }
}
@end
