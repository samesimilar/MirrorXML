//
//  MXPattern.m
//  MirrorXML
//
//  Created by Mike Spears on 2014-04-17.
//  Copyright (c) 2014 samesimilar. All rights reserved.
//

#import <libxml/pattern.h>

#import "MXPattern.h"

@interface MXPattern ()

@property (nonatomic, assign) xmlPatternPtr patternPtr;

/* hold reference to these in case libxml doesn't copy the cstrings internally */
@property (nonatomic) NSDictionary * namespaceDictionary;
@property (nonatomic) NSString * patternString;
@end
@implementation MXPattern

- (id) initWithPatternString:(NSString *) pattern namespaces:(NSDictionary *) namespaces
{
    if (!pattern) {
        return nil;
    }
    self = [super init];
    if (self) {
        NSAssert(pattern, @"pattern must not be nil");
        self.patternString = [pattern lowercaseString];
        self.namespaceDictionary = namespaces;
        
        const xmlChar * patternCh = (xmlChar *)[_patternString cStringUsingEncoding:NSUTF8StringEncoding];
        
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
        
        
        NSAssert(_patternPtr != NULL, @"pattern compilation failed");
        
    }
    return self;
}

- (id) init
{
    return [self initWithPatternString:@"//*" namespaces:nil];
}

- (id) copyWithZone:(NSZone *)zone
{
    return [[[self class] alloc] initWithPatternString:self.patternString namespaces:self.namespaceDictionary];
    
}

- (void) dealloc
{
    xmlFreePattern(self.patternPtr);
}


@end
