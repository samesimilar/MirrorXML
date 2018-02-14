//
//  MXParserContext.h
//  MirrorXML
//
//  Created by Mike Spears on 2014-04-16.
//  Copyright (c) 2014 samesimilar. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MXHandler;
@class MXHandlerList;

NS_ASSUME_NONNULL_BEGIN

@interface MXParser : NSObject




//- (void) addParser:(MXParser *) parser;
- (instancetype) initWithMatches:(NSArray<MXHandler *> *) matches;
- (void) parseDataChunk:(NSData *) data;
- (void) dataFinished;
- (void) raiseError:(NSError *) error;
- (void) stopParsing;

@end

NS_ASSUME_NONNULL_END
