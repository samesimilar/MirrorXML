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

/**
 MXParser is the main interface for MirrorXML's xml parsing functionality . MXParser objects wrap libxml's pull-parser. MXParser objects take xml data and call the callbacks provided by MXMatch objects if matching paths are found.
 
 You can call -parseDataChunk: multiple times to parse a large document incrementally.
 
 Make sure to call -dataFinished when there is no more data to parse.
 
 You can detect errors during parsing (as reported by libxml) by using the errorHandler callback on MXMatch.
 
 @warning Only parse one document per MXParser object. Don't re-use instances of this class.
*/
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
