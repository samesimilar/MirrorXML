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

- (instancetype) initWithMatches:(NSArray<MXMatch *> *) matches;
- (void) parseDataChunk:(NSData *) data;
- (void) dataFinished;

@end

NS_ASSUME_NONNULL_END
