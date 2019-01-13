//
//  MXPatternStream.m
//  MirrorXML
//
//  Created by Mike Spears on 2014-04-17.
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
#import <libxml/pattern.h>
#import "MXPatternStream.h"
#import "MXPattern.h"


@interface MXPattern (Private)

@property (nonatomic, assign,readonly) xmlPatternPtr patternPtr;

@end

@interface MXPatternStream ()
@property (nonatomic) MXPattern * pattern;
@property (nonatomic, assign) xmlStreamCtxtPtr streamPtr;

@end
@implementation MXPatternStream

- (instancetype) initWithPattern:(MXPattern *) pattern
{
    self = [super init];
    if (self) {
        self.pattern = pattern;
        self.streamPtr = xmlPatternGetStreamCtxt(pattern.patternPtr);
    }
    return self;
}

- (instancetype) init
{
    MXPattern * p = [[MXPattern alloc] init];
    return [self initWithPattern:p];
    
}

- (MXPatternStreamMatch) streamPushString:(const xmlChar *) localName namespaceString:(const xmlChar *) namespace
{
    return xmlStreamPush(self.streamPtr, localName, namespace);
}

- (MXPatternStreamMatch) streamPushAttribute:(const xmlChar *) attrName namespaceString:(const xmlChar *) namespace
{
    return xmlStreamPushAttr(self.streamPtr, attrName, namespace);
}


- (MXPatternStreamMatch) streamPop
{
    return xmlStreamPop(self.streamPtr);
}

- (MXPatternStreamMatch) streamReset
{
    return [self streamPushString:NULL namespaceString:nil];
}
- (void) dealloc
{
    
    xmlFreeStreamCtxt(self.streamPtr);
}

@end
