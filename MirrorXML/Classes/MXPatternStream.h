//
//  MXPatternStream.h
//  MirrorXML
//
//  Created by Mike Spears on 2014-04-17.
//  Copyright (c) 2014 samesimilar. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MXPattern;

typedef NS_ENUM(int, MXPatternStreamMatch)  {
    MXPatternStreamMatchError = -1,
    MXPatternStreamMatchNotFound = 0,
    MXPatternStreamMatchFound = 1,
};

NS_ASSUME_NONNULL_BEGIN


@interface MXPatternStream : NSObject

@property (nonatomic, readonly) MXPattern * pattern;

- (instancetype) initWithPattern:(MXPattern *) pattern;
- (MXPatternStreamMatch) streamPushString:(nullable NSString *) name namespaceString:(nullable NSString *) namespace;
- (MXPatternStreamMatch) streamPushAttribute:(nullable NSString *) attrName namespaceString:(nullable NSString *) namespace;
- (MXPatternStreamMatch) streamPushText;
- (MXPatternStreamMatch) streamPop;
- (MXPatternStreamMatch) streamReset;

@end

NS_ASSUME_NONNULL_END
