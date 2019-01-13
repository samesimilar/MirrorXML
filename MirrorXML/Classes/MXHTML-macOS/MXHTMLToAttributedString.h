//
//  MXHTMLToAttributedString.h
//  UTStatus
//
//  Created by Mike Spears on 2014-10-14.
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

@import Cocoa;

@class MXHTMLImageAttachmentInfo;

FOUNDATION_EXPORT NSInteger const MXHTMLToAttirbutedStringParseError;

NS_ASSUME_NONNULL_BEGIN

/**
 Implement the MXHTMLToAttributedStringDelegate protocol to supply custom styling information to MXHTMLToAttributedString.
 
 A default implementation, with many customizable properties, is supplied in MXHTMLToAttributedStringDelegateDefault.
 */
@protocol MXHTMLToAttributedStringDelegate <NSObject>

/**
 The basic attributes for unstyled (body) text.
 
 This is where you set up the default font and paragraph style.
 
 @return A list of attributes to style the text with, for use in initializing an NSAttributedString. See NSAttributedString for more information.
 */
- (NSDictionary<NSAttributedStringKey, id> *) initialAttributes;

/**
 The attributes to apply to a span of text inside a particular tag.
 
 Tags that can be passed to this method are: pre, small, strong, b, em, i, code, h1, h2, h3.
 
 @param tag The tag name (lowercase).
 @param currentAttrs The current text attributes. Normally you would create a mutable copy of this and then modify the particular attributes needed to style the new tag.
 @return A list of attributes to style the text with, for use in initializing an NSAttributedString. See NSAttributedString for more information.
 */
- (NSDictionary<NSAttributedStringKey, id> *) attributesForTag:(NSString *) tag currentAttributes:(NSDictionary<NSAttributedStringKey, id> *) currentAttrs;

/**
 The attributes to apply to the first paragraph of an ordered list item..
 
 @param level How 'deep' this list is in embedded lists.
 @param index The item's number in the list.
 @param currentAttrs The current text attributes. Normally you would create a mutable copy of this and then modify the particular attributes needed to style the new item.
 @return A list of attributes to style the text with, for use in initializing an NSAttributedString. See NSAttributedString for more information.
 */
- (NSDictionary<NSAttributedStringKey, id> *) attributesForOrderedListLevel:(NSInteger) level itemIndex:(NSInteger) index currentAttributes:(NSDictionary<NSAttributedStringKey, id> *) currentAttrs;

/**
 The text to use as the prefix for the list item (e.g. 1., A), i., etc.).
 
 @param index The item's number in the list.
 @param level How 'deep' this list is in embedded lists.
 @return The string to use as the prefix.
 */
- (NSString *) textForOrderedListItemIndex:(NSInteger) index atListLevel:(NSInteger) level;


/**
 The attributes to apply to the first paragraph of an unordered list item..
 
 @param level How 'deep' this list is in embedded lists.
 @param currentAttrs The current text attributes. Normally you would create a mutable copy of this and then modify the particular attributes needed to style the new item.
 @return A list of attributes to style the text with, for use in initializing an NSAttributedString. See NSAttributedString for more information.
 */
- (NSDictionary<NSAttributedStringKey, id> *) attributesForUnorderedListLevel:(NSInteger) level currentAttributes:(NSDictionary<NSAttributedStringKey, id> *) currentAttrs;

/**
 The text to use as the prefix for the list item (e.g. a 'bullet' character).
 
 @param level How 'deep' this list is in embedded lists.
 @return The string to use as the prefix.
 */
- (NSString *) textForUnorderedListItemAtListLevel:(NSInteger) level;

/**
 The attributes to apply to the text inside an anchor ('a') tag. For example you might want to apply the NSLinkAttributeName attribute to create a clickable link.
 
 @param htmlAttributes A list of attributes and values found in the 'a' tag in the document, including (probably) the 'href' value.
 @param currentAttrs The current text attributes. Normally you would create a mutable copy of this and then modify the particular attributes needed to style the new item.
 @return A list of attributes to style the text with, for use in initializing an NSAttributedString. See NSAttributedString for more information.
 */
- (NSDictionary<NSAttributedStringKey, id> *) attributesForAnchorElementWithHTMLAttributes:(NSDictionary<NSString *, NSString *> *) htmlAttributes currentTextAttributes:(NSDictionary<NSAttributedStringKey, id> *) currentAttrs;

/**
 The attributes to apply to the second and remaining paragraphs of an ordered list item.
 
 @param level How 'deep' this list is in embedded lists.
 @param currentAttrs The current text attributes. Normally you would create a mutable copy of this and then modify the particular attributes needed to style the new item.
 @return A list of attributes to style the text with, for use in initializing an NSAttributedString. See NSAttributedString for more information.
 */
- (NSDictionary<NSAttributedStringKey, id> *) attributesForOrderedListRemainingParagraphsAtLevel:(NSInteger) level currentAttributes:(NSDictionary<NSAttributedStringKey, id> *) currentAttrs;

/**
 The attributes to apply to the second and remaining paragraphs of an unordered list item..
 
 @param level How 'deep' this list is in embedded lists.
 @param currentAttrs The current text attributes. Normally you would create a mutable copy of this and then modify the particular attributes needed to style the new item.
 @return A list of attributes to style the text with, for use in initializing an NSAttributedString. See NSAttributedString for more information.
 */
- (NSDictionary<NSAttributedStringKey, id> *) attributesForUnorderedListRemainingParagraphsAtLevel:(NSInteger) level currentAttributes:(NSDictionary<NSAttributedStringKey, id> *) currentAttrs;


@end

/**
 MXHTMLToAttributedString can parse a basic html string into a styled NSMutableAttributedString.
 
 The advantage of this over NSAttributedString's html->string conversion method is that:
 
 1. You can customize the styling during parsing using a delegate.
 
 2. You can use this on any thread.
 
 3. It seems to be faster (don't call me or anything if it's not).
 
 It only handles basic 'Markdown-style' html tags, links and images. It doesn't handle scripts or stylesheets or anything fancy like that.
 
 Assign an object to the MXHTMLToAttributedStringDelegate delegate property to customize the font and paragraph attributes of the resulting text.
 
 An instance of MXHTMLToAttributedStringDelegateDefault, which has many customizeable properties, is assigned to the delegate property by default.
 
 libxml's html parser is not strict, so any errors that are encountered are not necessarily fatal. After you convert a string you can check the 'errors' property for any errors that were reported during parsing.
 
 It doesn't necessarily require the input to be a full 'html' structured document with stuff like 'head' and 'body' - so you can parse a simple string with a few tags into an attributed string, e.g. `<a>Click href="mailto:support@example.com"here</a> to <b>contact support.</b>` (Note: if you want links to be active inside something like a UILabel, make sure to enable user interaction with the UILabel.)
 
 If image tags are encountered: a placeholder is inserted, and you can insert the required image later using +insertImage:withInfo:toString.
 
 @warning This is all somewhat experimental, especially with respect to whitespace collapsing in html documents and paragraph spacing, so you may not necessarily get the results you expect. But it seems to be good for most basic cases.
 
 */
@interface MXHTMLToAttributedString : NSObject

/**
 Assign an object to the MXHTMLToAttributedStringDelegate delegate property to customize the font and paragraph attributes of the resulting text.
 
 An instance of MXHTMLToAttributedStringDelegateDefault, which has many customizeable properties, is assigned to the delegate property by default.
 */
@property (nonatomic, assign) id <MXHTMLToAttributedStringDelegate> delegate;

/**
 Check this property just after conversion to get a list of image tags found in the html string. You can then load the images and insert them into the string using +insertImage:withInfo:toString.
 
 @see +insertImage:withInfo:toString
 */
@property (nonatomic, readonly) NSArray<MXHTMLImageAttachmentInfo *> * imageAttachments;

/**
 Check this property just after conversion to get a list of errors encountered by libxml while parsing the html.
 */
@property (nonatomic, readonly, nullable) NSArray<NSError *> * errors;

/**
 Set this to NO (false) to prevent the MXHTMLToAttributedString object from saving errors during parsing. This may speed things up a little. The default value is YES (true).
 */
@property (nonatomic, assign) BOOL saveParsingErrors;

/**
 Convert an html string into an NSMutableAttributedString.
 
 It only handles basic 'Markdown-style' html tags, links and images. It doesn't handle scripts or stylesheets or anything fancy like that.
 
 Assign an object to the MXHTMLToAttributedStringDelegate delegate property to customize the font and paragraph attributes of the resulting text.
 
 An instance of MXHTMLToAttributedStringDelegateDefault, which has many customizeable properties, is assigned to the delegate property by default.
 
 libxml's html parser is not strict, so any errors that are encountered are not necessarily fatal. After you convert a string you can check the 'errors' property for any errors that were reported during parsing.
 
 It doesn't necessarily require the input to be a full 'html' structured document with stuff like 'head' and 'body' - so you can parse a simple string with a few tags into an attributed string, e.g. `<a>Click href="mailto:support@example.com"here</a> to <b>contact support.</b>` (Note: if you want links to be active inside something like a UILabel, make sure to enable user interaction with the UILabel.)
 
 If image tags are encountered: a placeholder is inserted, and you can insert the required image later using +insertImage:withInfo:toString.
 
 @param html The complete html document (or complete snippet) to parse.
 @return An NSMutableAttributedString styled according to the html tags found in the input. Don't modify this string if you will be later inserting images with +insertImage:withInfo:toString.
 */
- (NSMutableAttributedString *) convertHTMLString:(NSString *) html;

/**
 Use this to supply images for placeholders. The MXHTMLImageAttachmentInfo objects store placeholder locations as NSRanges, so if you modify the attributed string before inserting the images, the placeholder locations will be undefined.
 
 @param image The image to insert.
 @param info The associated placeholder info indicating where to insert the image.
 @param string The string where the image will be inserted.
 */
+ (void) insertImage:(NSImage *) image withInfo:(MXHTMLImageAttachmentInfo *) info toString:(NSMutableAttributedString *) string;
@end

NS_ASSUME_NONNULL_END
