//
//  MXHandler.h
//  MirrorXML
//
//  Created by Mike Spears on 2014-04-18.
//  Copyright (c) 2014 samesimilar. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MXPatternStream, MXElement, MXAttributeElement, MXPattern, MXParser, MXMatch;

NS_ASSUME_NONNULL_BEGIN

typedef NSArray<MXMatch *> * _Nullable(^MXStartElementHandler)(MXElement *);
typedef void            (^MXEndElementHandler)(MXElement *);
typedef void            (^MXTextHandler)(MXElement *);
typedef void            (^MXAttributeHandler)(MXAttributeElement *);
typedef void            (^MXErrorHandler)(NSError *, MXElement *);

@interface MXMatch : NSObject
@property (nonatomic, copy) MXStartElementHandler entryHandler;
@property (nonatomic, copy) MXEndElementHandler exitHandler;
@property (nonatomic, copy) MXTextHandler textHandler;
@property (nonatomic, copy) MXAttributeHandler attributeHandler;
@property (nonatomic, copy) MXErrorHandler errorHandler;
@property (nonatomic, readonly) MXPattern * pattern;

- (nullable instancetype) initWithPath:(NSString *) path
                            namespaces:(nullable NSDictionary<NSString *, NSString *> *)namespaces
                                 error:(NSError **) error;
- (nullable instancetype) initWithPath:(NSString *) path
                                 error:(NSError **)error;
- (instancetype) initWithPattern:(nullable MXPattern *) pattern;
+ (instancetype) onRootExit: (MXEndElementHandler) exitHandler;

@end

NS_ASSUME_NONNULL_END
