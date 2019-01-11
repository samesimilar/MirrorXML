//
//  MXHandlerList.m
//  MirrorXML
//
//  Created by Mike Spears on 2014-04-21.
//  Copyright (c) 2014 samesimilar. All rights reserved.
//

#import <libxml/tree.h>
#import <libxml/parser.h>
#import "MXMatchList.h"
#import "MXPattern.h"

#import "MXMatch.h"
#import "MXElement.h"
#import "MXAttributeElement.h"
#import "MXTextElement.h"

@interface MXElement ()

@property (nonatomic, assign) const xmlChar *xmlLocalname;
@property (nonatomic, assign) const xmlChar *xmlNamespaceURI;
@property (nonatomic, assign) int xmlNb_attributes;
@property (nonatomic, assign) const xmlChar **xmlAttributes;
@property (nonatomic, assign) BOOL attributesExpired;
@property (nonatomic, weak, nullable) id livingParserContext;
@property (nonatomic, nullable) MXElement *parent;

- (void)appendCharacters:(const char *)charactersFound
                  length:(NSInteger)length;

- (instancetype) initWithContext:(nullable id) context;
- (void) reset;

@end


@interface MXAttributeElement()

@property (nonatomic, assign) const xmlChar *xmlAttrName;
@property (nonatomic, assign) const xmlChar *xmlAttrValue;
@property (nonatomic, assign) NSUInteger xmlAttrValueLength;
@property (nonatomic, assign) const xmlChar *xmlAttrNamespace;

@end
@interface MXMatch()

//- (void) enterElement:(MXElement *) elm;
- (void) enterElement:(MXElement *) elm handlers:(NSMutableArray *) handlers;
- (void) exitElement:(MXElement *) elm;
- (void) streamReset;
- (void) errorRaised:(NSError *) error onElement:(MXElement *) elm;
//@property (nonatomic, readonly) id returnedHandlers;

@end

@interface MXMatchList()

@property (nonatomic) MXMatchList * parentList;
@property (nonatomic) MXMatchList * child;
@property (nonatomic) MXAttributeElement * attrElement;
@property (nonatomic) MXTextElement * textElement;
@end
@implementation MXMatchList

- (id) init
{
    self = [super init];
    if (self){
        self.handlers = [NSMutableArray new];

    }
    return self;
}

- (void) reset {
    [self.handlers removeAllObjects];
}

- (void) removeChildren {
    // have to remove these so there is no reference loop
    [_child removeChildren];
    self.child = nil;
}

- (MXElement *) elm {
    if (!_elm) {
        _elm = [[MXElement alloc] init];
    }
    return _elm;
}

- (MXAttributeElement *) attrElement {
    if (!_attrElement) {
        _attrElement = [[MXAttributeElement alloc] init];
    }
    return _attrElement;
}

- (MXTextElement *) textElement {
    if (!_textElement) {
        _textElement = [[MXTextElement alloc] init];
    }
    return _textElement;
}

- (MXElement *) childElement {
    MXElement * childElement = self.child.elm;
    [childElement reset];
    childElement.parent = self.elm;
    return childElement;
}

- (MXTextElement *) childTextElement {
    MXTextElement * textElement = self.child.textElement;
    [textElement reset];
    textElement.parent = self.elm;
    return textElement;
}

- (MXMatchList *) child {
    if (!_child) {
        _child = [[MXMatchList alloc] init];
        _child.parentList = self;
    }
    return _child;
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
        [h enterElement:elm handlers:cl.handlers];
//        [h enterElement:elm];
////        NSArray * newHandlers = h.returnedHandlers;
//        if (newHandlers) {
////            cl.handlers = [newHandlers arrayByAddingObjectsFromArray:cl.handlers];
//            [cl.handlers addObjectsFromArray:newHandlers];
//
//        }

    }
    
    if (_parentList) {
        [_parentList enterElementWithElement:elm childList:cl];
    }
}

- (MXMatchList *) enterElement:(MXElement *) elm {
    
    MXMatchList * childList = self.child;
    [childList reset];
    
    [self enterElementWithElement:elm childList:childList];

    [childList streamReset];

    if (elm.nodeType != MXElementNodeTypeElement) {
        return childList;
    }
    if (elm.xmlNb_attributes > 0) {
        NSInteger index = 0;

        // share one instance since can be discarded right away
        MXAttributeElement * attrElement = childList.attrElement;
        [attrElement reset];
        attrElement.livingParserContext = elm.livingParserContext;

        for (NSInteger i = 0; i < elm.xmlNb_attributes; i++, index += 5)
        {
            //[localname/prefix/URI/value/en]

            if (elm.xmlAttributes[index + 3] != 0)
            {
                attrElement.xmlAttrName = elm.xmlAttributes[index];
                attrElement.xmlAttrNamespace = elm.xmlAttributes[index + 2];
                attrElement.xmlAttrValue = elm.xmlAttributes[index + 3];
                attrElement.xmlAttrValueLength = elm.xmlAttributes[index + 4] - elm.xmlAttributes[index + 3];

                MXMatchList* handlerList =  [childList enterElement:attrElement];
                [handlerList exitElement:attrElement];
            }
        }
    }
    // prevent user from reading attributes after they may have been overwritten by libxml
    elm.attributesExpired = YES;
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
//    elm.stop = NO;
    for (MXMatch * h in _handlers) {
        [h exitElement:elm];
    }
    
    if (_parentList) {
        [_parentList exitElement:elm];
    }
    
//    return _parentList;
}

- (void) exitElement
{
    
//    _elm.stop = NO;
//    return [self exitElement:_elm];
    [self exitElement:_elm];
    
    
}


- (void) streamReset
{
    for (MXMatch * h in _handlers)
    {
        [h streamReset];
    }
}
@end
