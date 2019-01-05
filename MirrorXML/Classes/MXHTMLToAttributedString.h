//
//  MXHTMLToAttributedString.h
//  UTStatus
//
//  Created by Mike Spears on 2014-10-14.
//  Copyright (c) 2014 samesimilar. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MXHTMLToAttributedStringDelegate <NSObject>

- (NSDictionary *) initialAttributes;
- (NSDictionary *) attributesForTag:(NSString *) tag currentAttributes:(NSDictionary *) currentAttrs;
- (NSDictionary *) attributesForOrderedListLevel:(NSInteger) level currentAttributes:(NSDictionary *) currentAttrs;
- (NSString *) textForOrderedListItemIndex:(NSInteger) index atListLevel:(NSInteger) level;
- (NSDictionary *) attributesForUnorderedListLevel:(NSInteger) level currentAttributes:(NSDictionary *) currentAttrs;
- (NSString *) textForUnorderedListItemAtListLevel:(NSInteger) level;
- (NSDictionary *) attributesForAnchorElementWithHTMLAttributes:(NSDictionary *) htmlAttributes currentTextAttributes:(NSDictionary *) currentAttrs;

- (NSDictionary *) attributesForOrderedListRemainingParagraphsAtLevel:(NSInteger) level currentAttributes:(NSDictionary *) currentAttrs;

- (NSDictionary *) attributesForUnorderedListRemainingParagraphsAtLevel:(NSInteger) level currentAttributes:(NSDictionary *) currentAttrs;


@end
@interface MXHTMLToAttributedString : NSObject

@property (nonatomic, assign) id <MXHTMLToAttributedStringDelegate> delegate;
@property (nonatomic, readonly) NSArray * imageSources;
- (NSMutableAttributedString *) convertHTMLString:(NSString *) html;

@end

