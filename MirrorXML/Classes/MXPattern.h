//
//  MXPattern.h
//  MirrorXML
//
//  Created by Mike Spears on 2014-04-17.
//  Copyright (c) 2014 samesimilar. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MXPattern : NSObject <NSCopying>

- (nullable instancetype) initWithPath:(NSString *) path namespaces:(nullable NSDictionary<NSString *, NSString *> *) namespaces;
@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> * namespaceDictionary;
@property (nonatomic, readonly) NSString * patternString;

@end

NS_ASSUME_NONNULL_END
