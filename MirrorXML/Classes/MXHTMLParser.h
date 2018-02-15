//
//  MXHTMLParserContext.h
//  MirrorXML
//
//  Created by Mike Spears on 2014-04-23.
//  Copyright (c) 2014 samesimilar. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MXMatch;
@class MXHandlerList;

NS_ASSUME_NONNULL_BEGIN

@interface MXHTMLParser : NSObject

- (instancetype) initWithMatches:(NSArray<MXMatch *> *) matches;
- (void) parseDataChunk:(NSData *) data;
- (void) dataFinished;

@end

NS_ASSUME_NONNULL_END
