//
//  MXHandler.m
//  MirrorXML
//
//  Created by Mike Spears on 2014-04-18.
//  Copyright (c) 2014 samesimilar. All rights reserved.
//

#import "MXMatch.h"
#import "MXPattern.h"
#import "MXPatternStream.h"
#import "MXElement.h"

@interface MXMatch ()
@property (nonatomic) MXPatternStream * matchStream;
@property (nonatomic) NSMutableArray * activeStack;
@end

@implementation MXMatch

- (instancetype) initWithPattern:(MXPattern *) pattern
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

- (nullable instancetype) initWithPath:(NSString *) path namespaces:(nullable NSDictionary<NSString *, NSString *> *)namespaces error:(NSError **) error
{
    MXPattern * pattern = [[MXPattern alloc] initWithPath:path namespaces:namespaces error:error];
    if (!pattern) {
        return nil;
    }
    return [self initWithPattern:pattern];
}

- (nullable instancetype) initWithPath:(NSString *) path error:(NSError **)error {
    return [self initWithPath:path namespaces:nil error:error];
}


- (MXPattern *) pattern
{
    return _matchStream.pattern;
    
}
- (instancetype) init
{
    return [self initWithPath:@"//*" error: nil];
}

+ (instancetype) matchRoot {
    return [[[self class] alloc] initWithPattern:nil];
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

- (void) errorRaised:(NSError *) error onElement:(MXElement *) elm
{
    if (_errorHandler && _activeStack.count > 0 && !((id)[_activeStack lastObject] == (id)[NSNull null]) && !elm.stop  ) {
        _errorHandler(error, elm);
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
