//
//  MXHandler.m
//  MirrorXML
//
//  Created by Mike Spears on 2014-04-18.
//  Copyright (c) 2014 samesimilar. All rights reserved.
//

#import "MXHandler.h"
#import "MXPattern.h"
#import "MXPatternStream.h"
#import "MXElement.h"

@interface MXHandler ()
@property (nonatomic) MXPatternStream * matchStream;
@property (nonatomic) NSMutableArray * activeStack;
@end

@implementation MXHandler

- (id) initWithPattern:(MXPattern *) pattern
{
    self = [super init];
    if (self) {
        if (pattern) {
            self.matchStream = [[MXPatternStream alloc] initWithPattern:pattern];
        }

        self.activeStack = [NSMutableArray new];
    }
    return self;
}

- (id) initWithPatternString:(NSString *) str namespaces:(NSDictionary *)namespaces
{
    MXPattern * pattern = [[MXPattern alloc] initWithPatternString:str namespaces:namespaces];
    return [self initWithPattern:pattern];
}

+ (instancetype) handlerWithPattern:(MXPattern *) pattern handlerBlocks:(NSDictionary *) blocks
{
    MXHandler * h = [[self alloc] initWithPattern:pattern];
    h.entryHandler = blocks[@"entry"];
    h.exitHandler = blocks[@"exit"];
    h.textHandler = blocks[@"text"];
    h.attributeHandler = blocks[@"attribute"];
    h.errorHandler = blocks[@"error"];
    return h;
    
}

+ (instancetype) handlerWithPatternString:(NSString*) str namespaces:(NSDictionary *) namespaces handlerBlocks:(NSDictionary *) blocks
{
    MXPattern * pattern = [[MXPattern alloc] initWithPatternString:str namespaces:namespaces];
    return [self handlerWithPattern:pattern handlerBlocks:blocks];
}

- (NSDictionary *) handlerBlockDict
{
    NSMutableDictionary * h = [NSMutableDictionary new];
    if (_entryHandler) h[@"entry"] = _entryHandler;
    if (_exitHandler) h[@"exit"] = _exitHandler;
    if (_textHandler) h[@"text"] = _textHandler;
    if (_attributeHandler) h[@"attribute"] = _attributeHandler;
    if (_errorHandler) h[@"error"] = _errorHandler;
    return h;
    
}

- (MXPattern *) pattern
{
    return _matchStream.pattern;
    
}
- (id) init
{
    return [self initWithPatternString:@"//*" namespaces:nil];
}

- (id) initRootExit {
    return [self initWithPattern:nil];
}

- (id) enterElement:(MXElement *) elm
{
    if (!_matchStream && elm.nodeType != MXElementNodeTypeText) {
        [_activeStack addObject:[NSNull null]];
        return nil;
    }
    id newHandlers = nil;
    int match;
    if (elm.nodeType == MXElementNodeTypeText) {
//        match = [_matchStream streamPushText];
//        if (match == MXPatternStreamMatchFound) {
//            if (_entryHandler) {
//                newHandlers = _entryHandler(elm);
//            }
//            
//            [_activeStack addObject:@YES];
//        }
        // libxml pattern matching doesn't handle text nodes so we'll take care of it manually here
        if (_textHandler && _activeStack.count > 0 && !((id)[_activeStack lastObject] == (id)[NSNull null]) ) {
            _textHandler(elm);
        }
    } else {
        match =  [_matchStream streamPushString:elm.elementName namespaceString:elm.namespaceURI];
        if (match == MXPatternStreamMatchFound) {
            if (_entryHandler && !elm.stop) {
                newHandlers = _entryHandler(elm);
            }
            
            [_activeStack addObject:@YES];
        } else {
            [_activeStack addObject:[NSNull null]];
        }
        
        for (NSString * attrName in elm.attributes)
        {
            int match = [_matchStream streamPushAttribute:attrName namespaceString:elm.namespaceURI];
            if (match == MXPatternStreamMatchFound)
            {
                if (_entryHandler && !elm.stop) {
                    _entryHandler(elm);
                }
                if (_exitHandler && !elm.stop) {
                    _exitHandler(elm);
                }
                
            }
            [_matchStream streamPop];
        }
    }
    
    

    return newHandlers;
    
}

- (void) exitElement:(MXElement *) elm
{
    if (elm.nodeType == MXElementNodeTypeText) {
        return;
    }
    // matchstream nil symantics indicate that this handler wants to be called when it exits the original root element
    if (!_matchStream && _activeStack.count == 0 && !elm.stop)  {
        _exitHandler(elm);
    } else {
        // this element was matched by the pattern
        if (_exitHandler && _activeStack.count > 0 && !((id)[_activeStack lastObject] == (id)[NSNull null]) && !elm.stop ) {
            _exitHandler(elm);
        }
        
    }
    
    
    [_activeStack removeLastObject];
    
    [_matchStream streamPop];
}

- (void) errorRaised:(NSError *) error onElement:(MXElement *) elm inParser:(MXParser *) parser
{
    if (_errorHandler && _activeStack.count > 0 && !((id)[_activeStack lastObject] == (id)[NSNull null]) && !elm.stop  ) {
        _errorHandler(error, elm, parser);
    }

}

//// TODO: neeed to call these from MXHandlerList
//- (void) foundCharacters:(NSString *) characters inElement:(MXElement *) elm {
//    if (_textHandler && _activeStack.count > 0 && !((id)[_activeStack lastObject] == (id)[NSNull null]) ) {
//        _textHandler(characters, elm);
//    }
//
//}
//
//- (void) foundAttribute:(NSString *) attributeName inElement:(MXElement *) elm {
//    if (_attributeHandler && _activeStack.count > 0 && !((id)[_activeStack lastObject] == (id)[NSNull null]) ) {
//        _attributeHandler(attributeName, elm);
//    }
//}


- (void) streamReset
{
    [_matchStream streamReset];
}
@end
