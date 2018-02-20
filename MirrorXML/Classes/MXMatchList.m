//
//  MXHandlerList.m
//  MirrorXML
//
//  Created by Mike Spears on 2014-04-21.
//  Copyright (c) 2014 samesimilar. All rights reserved.
//

#import "MXMatchList.h"
#import "MXPattern.h"

#import "MXMatch.h"
#import "MXElement.h"
#import "MXAttributeElement.h"

@interface MXElement()
@property (nonatomic) MXElement *parent;
@end;
@interface MXMatch()

- (id) enterElement:(MXElement *) elm;
- (void) exitElement:(MXElement *) elm;
- (void) streamReset;
- (void) errorRaised:(NSError *) error onElement:(MXElement *) elm;

@end

@interface MXMatchList()

@property (nonatomic) MXMatchList * parentList;


@end
@implementation MXMatchList

- (id) init
{
    self = [super init];
    if (self){
//        self.handlers = [NSMutableArray new];

    }
    return self;
}

//- (void)setObject:(id)object forKeyedSubscript:(id < NSCopying >)aKey
//{
//    MXMatch * newHandler;
//    
//    if ([(id)aKey isKindOfClass:[MXPattern class]]) {
//        newHandler = [MXMatch handlerWithPattern:[(MXPattern *) aKey copy] handlerBlocks:object];
//    } else {
//        newHandler = [MXMatch handlerWithPatternString:[(NSString *)aKey copy] namespaces:nil handlerBlocks:object];
//    }
//    
//    self.handlers = _handlers ? [_handlers arrayByAddingObject:newHandler] : @[newHandler];
//    
//    
//}
//
//- (id)objectForKeyedSubscript:(id)key
//{
//    NSString * str = [key isKindOfClass:[MXPattern class]] ? [(MXPattern *)key patternString] : key;
//    
//
//    for (MXMatch * h in _handlers)
//    {
//        if ([h.pattern.patternString isEqualToString:str]) {
//            return [h handlerBlockDict];
//        }
//        
//    }
//    return nil;
//}


- (void) enterElementWithElement:(MXElement *) elm childList:(MXMatchList *) cl
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

- (MXMatchList *) enterElement:(MXElement *) elm {
    
    MXMatchList * childList = [[MXMatchList alloc] init];
    childList.parentList = self;
    childList.elm = elm;
    elm.parent = self.elm;
    
    
    [self enterElementWithElement:elm childList:childList];
    
    [childList streamReset];
    

    
    return childList;
}

- (void) errorRaised:(NSError *) error onElement:(MXElement *) elm
{
    for (MXMatch * h in _handlers) {
        [h errorRaised:error onElement:elm];
    }
    if (_parentList) {
        [_parentList errorRaised:error onElement:elm];
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

- (MXMatchList *) exitElement
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
