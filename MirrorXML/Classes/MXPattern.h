//
//  MXPattern.h
//  MirrorXML
//
//  Created by Mike Spears on 2014-04-17.
//  Copyright (c) 2014 samesimilar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MXPattern : NSObject <NSCopying>
- (id) initWithPatternString:(NSString *) pattern namespaces:(NSDictionary *) namespaces;
@property (nonatomic, readonly) NSDictionary * namespaceDictionary;
@property (nonatomic, readonly) NSString * patternString;

@end
