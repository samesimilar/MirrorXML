//
//  MXHTMLParserContext.h
//  MirrorXML
//
//  Created by Mike Spears on 2014-04-23.
//  Copyright (c) 2014 samesimilar. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MXMatch;

NS_ASSUME_NONNULL_BEGIN

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
