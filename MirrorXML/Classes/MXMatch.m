//
//  MXHandler.m
//  MirrorXML
//
//  Created by Mike Spears on 2014-04-18.
//  Copyright (c) 2014 samesimilar. All rights reserved.
//

#import <libxml/tree.h>

#import "MXMatch.h"
#import "MXPattern.h"
#import "MXPatternStream.h"
#import "MXElement.h"
#import "MXAttributeElement.h"

@interface MXElement()
@property (nonatomic, assign, readonly, nullable) const xmlChar *localName;
@property (nonatomic, assign) const xmlChar *xmlNamespaceURI;

@end

@interface MXPatternStream()
- (MXPatternStreamMatch) streamPushString:(const xmlChar *) localName namespaceString:(const xmlChar *) namespace;
@end

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

+ (instancetype) onRootExit: (MXEndElementHandler) exitHandler {
    MXMatch * m = [[[self class] alloc] initWithPattern:nil];
    m.exitHandler = exitHandler;
    return m;
}

- (BOOL) isAtMatchedNode {
    // If the last element in the active stack is @YES (i.e. it matched the current element):
    return _activeStack.count > 0 && ((id)[_activeStack lastObject] != (id)[NSNull null]);
}

- (BOOL) isExitingRootNodeMatch {
    // matchstream nil symantics indicate that this handler wants to be called when it exits the original root element
    return !_matchStream && _activeStack.count == 0;
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
        // libxml pattern matching doesn't handle text nodes so we'll take care of it manually here.
        if (_textHandler && [self isAtMatchedNode]) {
            _textHandler(elm);
        }
    } else {
        if (elm.nodeType == MXElementNodeTypeElement) {
            match =  [_matchStream streamPushString:elm.localName namespaceString:elm.xmlNamespaceURI];
        } else if (elm.nodeType == MXElementNodeTypeAttribute){
            match = [_matchStream streamPushAttribute:((MXAttributeElement *)elm).attrName namespaceString:((MXAttributeElement *)elm).attrNamespace];
        } else {
            return newHandlers;
        }
        

        if (match == MXPatternStreamMatchFound) {
            if (_entryHandler && !elm.stop) {
                newHandlers = _entryHandler(elm);
            }
            [_activeStack addObject:@YES];
        } else {
            [_activeStack addObject:[NSNull null]];
        }
//
//        if (_attributeHandler) {
//            for (NSString * attrName in elm.attributes)
//            {
//                int match = [_matchStream streamPushAttribute:attrName namespaceString:elm.namespaceURI];
//                if (match == MXPatternStreamMatchFound)
//                {
//                    if (!elm.stop) {
//                        _attributeHandler(elm.attributes[attrName], elm);
//                    }
//                }
//                [_matchStream streamPop];
//            }
//        }

    }
    
    

    return newHandlers;
    
}

- (void) exitElement:(MXElement *) elm
{
    if (elm.nodeType == MXElementNodeTypeText) {
        return;
    }
    
    if ([self isExitingRootNodeMatch] && !elm.stop)  {
        _exitHandler(elm);
    } else if (_exitHandler && [self isAtMatchedNode] && !elm.stop ) {
            _exitHandler(elm);
    }
    
    [_activeStack removeLastObject];
    [_matchStream streamPop];
    
}

- (void) errorRaised:(NSError *) error onElement:(MXElement *) elm
{
    if (_errorHandler && [self isAtMatchedNode] && !elm.stop  ) {
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
