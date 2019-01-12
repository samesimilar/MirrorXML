//
//  MXHTMLToAttributedString.h
//  UTStatus
//
//  Created by Mike Spears on 2014-10-14.
//  Copyright (c) 2014 samesimilar. All rights reserved.
//

@import Cocoa;

@class MXHTMLImageAttachmentInfo;

FOUNDATION_EXPORT NSInteger const MXHTMLToAttirbutedStringParseError;

NS_ASSUME_NONNULL_BEGIN
@protocol MXHTMLToAttributedStringDelegate <NSObject>

- (NSDictionary *) initialAttributes;
- (NSDictionary *) attributesForTag:(NSString *) tag currentAttributes:(NSDictionary *) currentAttrs;
- (NSDictionary *) attributesForOrderedListLevel:(NSInteger) level itemIndex:(NSInteger) index currentAttributes:(NSDictionary *) currentAttrs;
- (NSString *) textForOrderedListItemIndex:(NSInteger) index atListLevel:(NSInteger) level;
- (NSDictionary *) attributesForUnorderedListLevel:(NSInteger) level currentAttributes:(NSDictionary *) currentAttrs;
- (NSString *) textForUnorderedListItemAtListLevel:(NSInteger) level;
- (NSDictionary *) attributesForAnchorElementWithHTMLAttributes:(NSDictionary *) htmlAttributes currentTextAttributes:(NSDictionary *) currentAttrs;

- (NSDictionary *) attributesForOrderedListRemainingParagraphsAtLevel:(NSInteger) level currentAttributes:(NSDictionary *) currentAttrs;

- (NSDictionary *) attributesForUnorderedListRemainingParagraphsAtLevel:(NSInteger) level currentAttributes:(NSDictionary *) currentAttrs;


@end

@interface MXHTMLToAttributedString : NSObject

@property (nonatomic, assign) id <MXHTMLToAttributedStringDelegate> delegate;
@property (nonatomic, readonly) NSArray<MXHTMLImageAttachmentInfo *> * imageAttachments;
@property (nonatomic, readonly, nullable) NSArray<NSError *> * errors;
@property (nonatomic, assign) BOOL detectParsingErrors;
- (NSMutableAttributedString *) convertHTMLString:(NSString *) html;
+ (void) insertImage:(NSImage *) image withInfo:(MXHTMLImageAttachmentInfo *) info toString:(NSMutableAttributedString *) string;
@end

NS_ASSUME_NONNULL_END
