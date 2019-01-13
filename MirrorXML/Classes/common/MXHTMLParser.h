//
//  MXHTMLParserContext.h
//  MirrorXML
//
//  Created by Mike Spears on 2014-04-23.
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
@class MXMatch;

NS_ASSUME_NONNULL_BEGIN

/**
 MXHTMLParser is the main interface for MirrorXML's html4 parsing functionality . MXHTMLParser objects wrap libxml's html4 pull-parser. MXHTMLParser objects take html data and call the callbacks provided by MXMatch objects if matching paths are found.
 
 You can call -parseDataChunk: multiple times to parse a large document incrementally.
 
 Make sure to call -dataFinished when there is no more data to parse.
 
 You can detect errors during parsing (as reported by libxml) by using the errorHandler callback on MXMatch.
 
 @warning Only parse one document per MXParser object. Don't re-use instances of this class.
 */
@interface MXHTMLParser : NSObject

/**
 Returns a new html parser object that is ready to accept html 4.0 data.
 
 Create a separate instance of this class for each individual document.
 
 @param matches An array of MXMatch objects to match with the document.
*/
- (instancetype) initWithMatches:(NSArray<MXMatch *> *) matches;

/**
 Parse a chunk of html data. Callbacks for any patterns that are matched in this data will be called before this function returns.
 
 @param data The html data to parse. The data does not need to contain the complete html document. (This method can be called multiple times to pass the full document.)
*/
- (void) parseDataChunk:(NSData *) data;

/**
 This method must be called when there is no more data to parse.
*/
- (void) dataFinished;

@end

NS_ASSUME_NONNULL_END
