//
//  MXHTMLToAttributedStringDelegateDefault.h
//  UTStatus
//
//  Created by Mike Spears on 2014-10-15.
//  Copyright (c) 2014 samesimilar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MXHTMLToAttributedString.h"
NS_ASSUME_NONNULL_BEGIN
@interface MXHTMLToAttributedStringDelegateDefault : NSObject <MXHTMLToAttributedStringDelegate>
@property (nonatomic, assign)   NSLineBreakMode  lineBreakMode;
@property (nonatomic)  UIFont *         bodyFont;
@property (nonatomic)  UIFont *         h1Font;
@property (nonatomic)  UIFont *         h2Font;
@property (nonatomic)  UIFont *         h3Font;
// See NSParagraphStyle documentation for notes on paragraph spacing values. Default value for both here is 0.
@property (nonatomic, assign) 	CGFloat          normalParagraphSpacing;
@property (nonatomic, assign) 	CGFloat          normalParagraphSpacingBefore;
// The base font to use for <code> or preformatted (i.e. <pre>) text. Size will be based on context of usage (usually bodyFont point size). Default is Courier.
@property (nonatomic) 	UIFont *         monospaceFont;
// By default <pre>formatted text will be clipped and not word-wrapped (The default value of this property is NSLineBreakByClipping).
@property (nonatomic, assign)   NSLineBreakMode  preformattedTextLineBreakMode;
// The default value is "%ld. ". Used with [NSString stringWithFormat:@"%ld. ", itemNumber].
@property (nonatomic)  NSString *       orderedListItemPrefixFormat;
// Bullet point plus leading space for unordered list items.
@property (nonatomic)  NSString *       unorderedListItemPrefix;
// Controls the size of each indentation 'step' for nested lists. This is multiplied by the point size of a single space in the current font.
@property (nonatomic, assign)   int              listItemIndentCharacterCount;
@end
NS_ASSUME_NONNULL_END
