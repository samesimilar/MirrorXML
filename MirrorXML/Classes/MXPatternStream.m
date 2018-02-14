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

- (id) initWithPattern:(MXPattern *) pattern
{
    self = [super init];
    if (self) {
        NSAssert(xmlPatternStreamable(pattern.patternPtr) == 1, @"xmlPattern must be streamable");
        
        self.pattern = pattern;
        
        self.streamPtr = xmlPatternGetStreamCtxt(pattern.patternPtr);
        


    }
    return self;
}

- (id) init
{
    MXPattern * p = [[MXPattern alloc] init];
    return [self initWithPattern:p];
    
}

- (MXPatternStreamMatch) streamPushString:(NSString *) name namespaceString:(NSString *) namespace;
{
    const xmlChar * nameCh = name ? (xmlChar *)[name cStringUsingEncoding:NSUTF8StringEncoding] : NULL;
    const xmlChar * namespaceCh = namespace ? (xmlChar *)[namespace cStringUsingEncoding:NSUTF8StringEncoding] : NULL;
    return xmlStreamPush(self.streamPtr, nameCh, namespaceCh);
    
}

- (MXPatternStreamMatch) streamPushAttribute:(NSString *) attrName namespaceString:(NSString *) namespace
{
    const xmlChar * nameCh = attrName ? (xmlChar *)[attrName cStringUsingEncoding:NSUTF8StringEncoding] : NULL;
    const xmlChar * namespaceCh = namespace ? (xmlChar *)[namespace cStringUsingEncoding:NSUTF8StringEncoding] : NULL;
    return xmlStreamPushAttr(self.streamPtr, nameCh, namespaceCh);
}

- (MXPatternStreamMatch) streamPushText
{
    return xmlStreamPushNode(self.streamPtr, NULL, NULL, XML_TEXT_NODE);
}

- (MXPatternStreamMatch) streamPop
{
    return xmlStreamPop(self.streamPtr);
}

- (MXPatternStreamMatch) streamReset
{
    return [self streamPushString:nil namespaceString:nil];
}
- (void) dealloc
{
    
    xmlFreeStreamCtxt(self.streamPtr);
}

@end
