//
//  MXHandler.m
//  MirrorXML
//
//  Created by Mike Spears on 2014-04-18.
//  Copyright (c) 2014 samesimilar. All rights reserved.
//
/*
 Copyright (c) 2018 Michael Spears <help@samesimilar.com>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */

#import <libxml/tree.h>

#import "MXMatch.h"
#import "MXPattern.h"
#import "MXPatternStream.h"
#import "MXElement.h"
#import "MXAttributeElement.h"

@interface MXElement()
@property (nonatomic, assign) const xmlChar *xmlLocalname;
@property (nonatomic, assign) const xmlChar *xmlNamespaceURI;
@property (nonatomic, assign) BOOL stop;
- (void) buildAttributesDictionary;
@end

@interface MXAttributeElement()
@property (nonatomic, assign) const xmlChar *xmlAttrName;
@property (nonatomic, assign) const xmlChar *xmlAttrNamespace;
@end


@interface MXPatternStream()
- (MXPatternStreamMatch) streamPushString:(const xmlChar *) localName namespaceString:(const xmlChar *) namespace;
- (MXPatternStreamMatch) streamPushAttribute:(const xmlChar *) attrName namespaceString:(const xmlChar *) namespace;
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

- (nullable instancetype) initWithPath:(NSString *) path namespaces:(nullable NSDictionary<NSString *, NSString *> *)namespaces error:(NSError * __nullable * __null_unspecified) error
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

- (void) enterElement:(MXElement *) elm handlers:(NSMutableArray *) handlers
{
    if (!_matchStream && elm.nodeType != MXElementNodeTypeText) {
        [_activeStack addObject:[NSNull null]];
        return;
    }
    int match;
    if (elm.nodeType == MXElementNodeTypeText) {
        // libxml pattern matching doesn't handle text nodes so we'll take care of it manually here.
        if (_textHandler && [self isAtMatchedNode]) {
            _textHandler(elm);
        }
    } else {
        if (elm.nodeType == MXElementNodeTypeElement) {
            match =  [_matchStream streamPushString:elm.xmlLocalname namespaceString:elm.xmlNamespaceURI];
        } else if (elm.nodeType == MXElementNodeTypeAttribute){
            match = [_matchStream streamPushAttribute:((MXAttributeElement *)elm).xmlAttrName namespaceString:((MXAttributeElement *)elm).xmlAttrNamespace];
        } else {
            return;
        }
        

        if (match == MXPatternStreamMatchFound) {
            // if this node matches, we have to pre-convert the attributes dictionary to strings instead of lazily converting it on access
            // Why? because if libxml finds special characters in the attribute value, it creates a tmp string somewhere to store
            // decoded characters, which seems to be released after this stage of parsing
            // edit: to avoid creating unneccesary objects and strings, we'll only make this available during the "enterElement" phase
//            [elm buildAttributesDictionary];
            if (_entryHandler && !elm.stop && elm.nodeType == MXElementNodeTypeElement) {
                NSArray * newHandlers = _entryHandler(elm);
                if (newHandlers) {
                    [handlers addObjectsFromArray:newHandlers];
                }
            }
            [_activeStack addObject:@YES];
        } else {
            [_activeStack addObject:[NSNull null]];
        }

    }
    
    

    return;
    
}

- (void) exitElement:(MXElement *) elm
{
    if (elm.nodeType == MXElementNodeTypeText) {
        return;
    }
    
    if ([self isExitingRootNodeMatch] && !elm.stop)  {
        _exitHandler(elm);
    } else if (_exitHandler && [self isAtMatchedNode] && !elm.stop && elm.nodeType == MXElementNodeTypeElement) {
        _exitHandler(elm);
    } else if (_attributeHandler && elm.nodeType == MXElementNodeTypeAttribute && [self isAtMatchedNode]) {
        _attributeHandler((MXAttributeElement *) elm);
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

- (void) streamReset
{
    [_matchStream streamReset];
}
@end
