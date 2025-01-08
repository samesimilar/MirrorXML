//
//  MXHTMLToAttributedStringDelegateDefault.h
//  UTStatus
//
//  Created by Mike Spears on 2014-10-15.
//  Copyright (c) 2014 samesimilar. All rights reserved.
//
/*
 Copyright (c) 2018 Michael Spears <help@samesimilar.com>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */

#import <UIKit/UIKit.h>
#import "MXHTMLToAttributedString.h"

NS_ASSUME_NONNULL_BEGIN

/**
 A basic implementation of the MXHTMLToAttributedStringDelegate protocol.
 
 To get custom styling you could either set the properties of this object, or subclass it.
*/
@interface MXHTMLToAttributedStringDelegateDefault : NSObject <MXHTMLToAttributedStringDelegate>

@property (nonatomic, assign)   NSLineBreakMode  lineBreakMode;
@property (nonatomic)  UIFont *         bodyFont;
@property (nonatomic)  UIFont *         h1Font;
@property (nonatomic)  UIFont *         h2Font;
@property (nonatomic)  UIFont *         h3Font;
@property (nonatomic)  UIFont *         h4Font;

/**
 See NSParagraphStyle documentation for notes on paragraph spacing values. Default value for both here is 0.
*/
@property (nonatomic, assign) 	CGFloat          normalParagraphSpacing;

/**
 See NSParagraphStyle documentation for notes on paragraph spacing values. Default value for both here is 0.
 */
@property (nonatomic, assign) 	CGFloat          normalParagraphSpacingBefore;

/**
 The base font to use for 'code' or preformatted (i.e. 'pre') text. Size will be based on context of usage (usually bodyFont point size). Default is Courier.
*/
@property (nonatomic) 	UIFont *         monospaceFont;

/**
  By default 'pre'-formatted text will be clipped and not word-wrapped (The default value of this property is NSLineBreakByClipping).
*/
@property (nonatomic, assign)   NSLineBreakMode  preformattedTextLineBreakMode;

/**
 The default value is "%ld. ". Used with [NSString stringWithFormat:@"%ld. ", itemNumber].
*/
@property (nonatomic)  NSString *       orderedListItemPrefixFormat;

/**
 Bullet point plus leading space for unordered list items.
*/
@property (nonatomic)  NSString *       unorderedListItemPrefix;

/**
  Controls the size of each indentation 'step' for nested lists. This is multiplied by the point size of a single space in the current font.
*/
@property (nonatomic, assign)   int              listItemIndentCharacterCount;
@end
NS_ASSUME_NONNULL_END
