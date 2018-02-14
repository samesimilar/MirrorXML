//
//  MXParserContext.h
//  MirrorXML
//
//  Created by Mike Spears on 2014-04-16.
//  Copyright (c) 2014 samesimilar. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MXHandlerList;

@interface MXParser : NSObject
@property (nonatomic) MXHandlerList * handlerList;

//- (void) addParser:(MXParser *) parser;
- (void) parseDataChunk:(NSData *) data;
- (void) dataFinished;
- (void) raiseError:(NSError *) error;
- (void) stopParsing;

@end
