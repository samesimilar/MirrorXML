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

- (nullable instancetype) initWithPath:(NSString *) path
                            namespaces:(nullable NSDictionary<NSString *, NSString *> *) namespaces
                                 error:(NSError **)error;

@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> * namespaces;
@property (nonatomic, readonly) NSString * path;

@end

NS_ASSUME_NONNULL_END
