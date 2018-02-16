//
//  MXPattern.m
//  MirrorXML
//
//  Created by Mike Spears on 2014-04-17.
//  Copyright (c) 2014 samesimilar. All rights reserved.
//

#import <libxml/pattern.h>

#import "MXPattern.h"

NSErrorDomain MirrorXMLErrorDomain = @"com.samesimilar.MirrorXML";

@interface MXPattern ()

@property (nonatomic, assign) xmlPatternPtr patternPtr;

/* hold reference to these in case libxml doesn't copy the cstrings internally */
@property (nonatomic) NSDictionary<NSString *, NSString *> * namespaces;
@property (nonatomic) NSString * path;
@end
@implementation MXPattern

- (nullable instancetype) initWithPath:(NSString *) path
                            namespaces:(nullable NSDictionary<NSString *, NSString *> *) namespaces
                                 error:(NSError **)error
{

    self = [super init];
    if (self) {
        
        self.path = [path lowercaseString];
        self.namespaces = namespaces ? namespaces : [NSDictionary new];
        
        const xmlChar * patternCh = (xmlChar *)[_path cStringUsingEncoding:NSUTF8StringEncoding];
        
        const xmlChar ** namespacesCh  = NULL;
        if (namespaces) {
            NSUInteger numNamespaces = [namespaces count];
            namespacesCh = calloc(numNamespaces * 2 + 2, sizeof(xmlChar *));
            const xmlChar ** iNamespace = namespacesCh;
            for (NSString * shortName in namespaces) {
                NSString * longName= namespaces[shortName];
                // stored as array of [URI, prefix]
                iNamespace[0] = (xmlChar * )[longName cStringUsingEncoding:NSUTF8StringEncoding];
                iNamespace[1] = (xmlChar * )[[shortName lowercaseString] cStringUsingEncoding:NSUTF8StringEncoding];
                iNamespace += 2;
            }
            //terminator
            iNamespace[0] = NULL;
            iNamespace[1] = NULL;

        }

        self.patternPtr = xmlPatterncompile(patternCh, NULL, XML_PATTERN_XPATH, namespacesCh);
        
        free(namespacesCh);
        
        if (_patternPtr == NULL) {
            if (error) {
                *error = [NSError errorWithDomain:MirrorXMLErrorDomain code:MirrorXMLErrorPathParseFailed userInfo:nil];
            }
            return nil;
        }
        
        // pattern must be streamable
        if (xmlPatternStreamable(_patternPtr) != 1) {
            if (error) {
                *error = [NSError errorWithDomain:MirrorXMLErrorDomain code:MirrorXMLErrorPathIsNotStreamable userInfo:nil];
            }
            return nil;
        }
        
    }
    return self;
}

- (instancetype) init
{
    return [self initWithPath:@"//*" namespaces:nil error:nil];
}

- (instancetype) copyWithZone:(NSZone *)zone
{
    return [[[self class] alloc] initWithPath:self.path namespaces:self.namespaces error: nil];
    
}

- (void) dealloc
{
    xmlFreePattern(self.patternPtr);
}


@end
