//
//  MXPatternStream.m
//  MirrorXML
//
//  Created by Mike Spears on 2014-04-17.
//  Copyright (c) 2014 samesimilar. All rights reserved.
//
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
//        NSAssert(xmlPatternStreamable(pattern.patternPtr) == 1, @"xmlPattern must be streamable");
        
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
//    const xmlChar * nameCh = name ? (xmlChar *)[name cStringUsingEncoding:NSUTF8StringEncoding] : NULL;
//    const xmlChar * namespaceCh = namespace ? (xmlChar *)[namespace cStringUsingEncoding:NSUTF8StringEncoding] : NULL;
    return xmlStreamPush(self.streamPtr, localName, namespace);
    
}

- (MXPatternStreamMatch) streamPushAttribute:(const xmlChar *) attrName namespaceString:(const xmlChar *) namespace
{
//    const xmlChar * nameCh = attrName ? (xmlChar *)[attrName cStringUsingEncoding:NSUTF8StringEncoding] : NULL;
//    const xmlChar * namespaceCh = namespace ? (xmlChar *)[namespace cStringUsingEncoding:NSUTF8StringEncoding] : NULL;
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