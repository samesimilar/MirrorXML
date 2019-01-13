//
//  MXPattern.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSErrorDomain MirrorXMLErrorDomain;

typedef enum : NSUInteger {
    MirrorXMLLibXMLError,
    MirrorXMLErrorPathParseFailed,
    MirrorXMLErrorPathIsNotStreamable
} MirrorXMLError;

/**
 MXPattern objects represent an XPath-style pattern matching path that has been compiled into an object that can be used with MXMatch objects.
 
 You can either create these objects directly and use them to initialize MXMatch objects, or you can use MXMatch's convenience constructors to have them implicitly created.
 
 MXPattern objects are immutable and can be re-used between multiple MXMatch objects and parser contexts. This can save some processing if you have to match the same path over and over again (e.g. returning an MXMatch instance from an entryHandler block).
*/
@interface MXPattern : NSObject <NSCopying>

/**
 Returns an initialized MXPattern object that can be used to match an XPath-style path.
 
 MXPattern objects are immutable and can be re-used between multiple MXMatch objects and parser contexts. This can save some processing if you have to match the same path over and over again (e.g. returning an MXMatch instance from an entryHandler block).
 
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
 
 @see -initWithPath:namespaces:error
*/
@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> * namespaces;

/**
 The path string used to create this object. Read only.
 
 @see -initWithPath:namespaces:error
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
