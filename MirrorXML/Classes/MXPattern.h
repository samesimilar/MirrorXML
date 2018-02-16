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

- (instancetype _Nullable) initWithPath:(NSString *) path namespaces:(NSDictionary<NSString *, NSString *> * _Nullable) namespaces;
@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> * namespaceDictionary;
@property (nonatomic, readonly) NSString * patternString;

@end

NS_ASSUME_NONNULL_END
