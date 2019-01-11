//
//  MXParserContext.h
//  MirrorXML
//
//  Created by Mike Spears on 2014-04-16.
//  Copyright (c) 2014 samesimilar. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MXMatch;

NS_ASSUME_NONNULL_BEGIN

@interface MXParser : NSObject
/**
 Creates a new parser object that is ready to accept xml data.
 
 Create a separate instance of this class for each individual xml document.
 
 @param matches An array of MXMatch object to match with the document.
*/
- (instancetype) initWithMatches:(NSArray<MXMatch *> *) matches;

/**
 Parse a chunk of xml data. Callbacks for any patterns that are matched in this data will be called before this function returns.
 
 @param data The xml data to parse. The data does not need to contain the complete xml document. (This method can be called multiple times to pass the full document.)
*/
- (void) parseDataChunk:(NSData *) data;

/**
 This method must be called when there is no more data to parse.
*/
- (void) dataFinished;

@end

NS_ASSUME_NONNULL_END
