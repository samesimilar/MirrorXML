//
//  MXHandlerList.m
//  MirrorXML
//
//  Created by Mike Spears on 2014-04-21.
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
@property (nonatomic, assign) BOOL stop;

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

- (void) enterElement:(MXElement *) elm handlers:(NSMutableArray *) handlers;
- (void) exitElement:(MXElement *) elm;
- (void) streamReset;
- (void) errorRaised:(NSError *) error onElement:(MXElement *) elm;

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


- (void) enterElementWithElement:(MXElement *) elm childList:(MXMatchList *) cl
{
    for (MXMatch * h in _handlers) {
        [h enterElement:elm handlers:cl.handlers];
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
                _attrElement.stop = NO;
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

    for (MXMatch * h in _handlers) {
        [h exitElement:elm];
    }
    
    if (_parentList) {
        [_parentList exitElement:elm];
    }
    

}

- (void) exitElement
{
    _elm.stop = NO;
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
