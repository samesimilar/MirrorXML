//
//  MXHandler.h
//  MirrorXML
//
//  Created by Mike Spears on 2014-04-18.
//  Copyright (c) 2014 samesimilar. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MXPatternStream, MXElement, MXPattern, MXParser;


typedef id              (^MXStartElementHandler)(MXElement *);
typedef void            (^MXEndElementHandler)(MXElement *);
typedef void            (^MXTextHandler)(MXElement *);
typedef void            (^MXAttributeHandler)(NSString *, MXElement *);
typedef void            (^MXErrorHandler)(NSError *, MXElement *, MXParser *);
@interface MXHandler : NSObject
@property (nonatomic, copy) MXStartElementHandler entryHandler;
@property (nonatomic, copy) MXEndElementHandler exitHandler;
@property (nonatomic, copy) MXTextHandler textHandler;
@property (nonatomic, copy) MXAttributeHandler attributeHandler;
@property (nonatomic, copy) MXErrorHandler errorHandler;
@property (nonatomic, readonly) MXPattern * pattern;

+ (instancetype) handlerWithPattern:(MXPattern *) pattern handlerBlocks:(NSDictionary *) blocks;
+ (instancetype) handlerWithPatternString:(NSString*) str namespaces:(NSDictionary *) namespaces handlerBlocks:(NSDictionary *) blocks;
- (NSDictionary *) handlerBlockDict;
- (id) enterElement:(MXElement *) elm;
- (void) exitElement:(MXElement *) elm;
- (void) streamReset;
- (void) errorRaised:(NSError *) error onElement:(MXElement *) elm inParser:(MXParser *) parser;

- (id) initWithPatternString:(NSString *) str namespaces:(NSDictionary *)namespaces;
- (id) initWithPattern:(MXPattern *) pattern;
- (id) initRootExit;

@end
