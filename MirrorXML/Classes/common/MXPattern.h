//
//  MXPattern.h
//  MirrorXML
//
//  Created by Mike Spears on 2014-04-17.
//  Copyright (c) 2014 samesimilar. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSErrorDomain MirrorXMLErrorDomain;

typedef enum : NSUInteger {
    MirrorXMLErrorPathParseFailed,
    MirrorXMLErrorPathIsNotStreamable
} MirrorXMLError;

@interface MXPattern : NSObject <NSCopying>

/**
 Returns an initialized MXPattern object that can be used to match an XPath-style path.
 
 MXPattern objects are immutable and can be re-used between multiple MXMatch objects and parser contexts.
 
 Element/attribute names are case-sensitive for xml contexts. They are case-insensitive for html contexts.
 
 Some examples:
 
 /root/child             --> Match 'child' elements that are children of 'root'
 
 /root/child/child       --> Match 'child' elements that are children of 'child' that are children of 'root'
 
 /root/child/@attrName   --> Match 'child' elements (that are children of 'root') that have an attribute named 'attrName'.
 
The asterisk character is a wildcard, it matches any element. Use it in place of an element name.
 
 //                      --> Path flattener. Use it in place of a '/' character. Matches the path that follows it at any level.
 
 /root/ns:child          --> The child element is specified with a namespace prefix. The 'ns' prefix is mapped to a full namespace URI in the namespaces dictionary parameter.
 
 @param path The path to match. This is a simplified XPath-style path, passed here as an NSString, and parsed by libxml. Complex predicates are not accepted.
 
 @param namespaces A dictionary mapping prefix keys to URI namespace values. The prefix is used to internally identify prefixes in the `path` parameter and doesn't necessarily refer to the arbitrary prefix would be used in the actual xml document being scanned.
 
 @param error Returns an NSError object if the path cannot be parsed for some reason.
*/
- (nullable instancetype) initWithPath:(NSString *) path
                            namespaces:(nullable NSDictionary<NSString *, NSString *> *) namespaces
                                 error:(NSError * __nullable * __null_unspecified)error;

/**
 The prefix-to-namespace map used to create this object. Read only.
 
 @see initWithPath:namespaces:error
*/
@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> * namespaces;

/**
 The path string used to create this object. Read only.
 
 @see initWithPath:namespaces:error
*/
@property (nonatomic, readonly) NSString * path;

/**
 The value returned by xmlPatternMaxDepth. Read only.
*/
@property (nonatomic, assign, readonly) int maxDepth;

/**
 The value returned by xmlPatternMinDepth. Read only.
*/
@property (nonatomic, assign, readonly) int minDepth;

/**
 TRUE if this pattern contains a parameter that matches an attribute (i.e. contains an '@' prefix at some level). Read only.
*/
@property (nonatomic, assign, readonly) BOOL matchesAttribute;


@end

NS_ASSUME_NONNULL_END
