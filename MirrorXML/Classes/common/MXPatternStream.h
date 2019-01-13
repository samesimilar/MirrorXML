//
//  MXPatternStream.h
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
//- (MXPatternStreamMatch) streamPushString:(nullable const xmlChar *) localName namespaceString:(nullable NSString *) namespace;
//- (MXPatternStreamMatch) streamPushAttribute:(nullable NSString *) attrName namespaceString:(nullable NSString *) namespace;
//- (MXPatternStreamMatch) streamPushText;
- (MXPatternStreamMatch) streamPop;
- (MXPatternStreamMatch) streamReset;

@end

NS_ASSUME_NONNULL_END
