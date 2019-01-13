//
//  MXHandlerList.h
//  MirrorXML
//
//  Created by Mike Spears on 2014-04-21.
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
@class MXElement, MXTextElement, MXParser;

NS_ASSUME_NONNULL_BEGIN

@interface MXMatchList : NSObject

@property (nonatomic, nullable) MXElement * elm;
@property (nonatomic, nullable) NSMutableArray * handlers;
@property (nonatomic, readonly) MXMatchList * parentList;


- (void) reset;
- (void) removeChildren;
- (MXMatchList *) enterElement:(MXElement *) elm;
- (void) exitElement;
- (void) exitElement:(MXElement *) elm;
- (void) streamReset;
- (void) errorRaised:(NSError *) error onElement:(nullable MXElement * ) elm;
- (MXElement *) childElement;
- (MXTextElement *) childTextElement;

@end

NS_ASSUME_NONNULL_END
