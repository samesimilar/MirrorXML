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

@interface MXPatternStream : NSObject
@property (nonatomic, readonly) MXPattern * pattern;
- (id) initWithPattern:(MXPattern *) pattern;

- (MXPatternStreamMatch) streamPushString:(NSString *) name namespaceString:(NSString *) namespace;
- (MXPatternStreamMatch) streamPushAttribute:(NSString *) attrName namespaceString:(NSString *) namespace;
- (MXPatternStreamMatch) streamPushText;
- (MXPatternStreamMatch) streamPop;
- (MXPatternStreamMatch) streamReset;

@end
