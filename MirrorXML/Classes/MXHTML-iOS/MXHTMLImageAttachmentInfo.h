//
//  MXHTMLImageAttachmentInfo.h
//  Pods
//
//  Created by Mike Spears on 2019-01-04.
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
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 MXHTMLImageAttachmentInfo encapsulate information about <img> tags found while converting html to an attributed string using MXHTMLToAttributedString.
 
 You retrieve instances of this class from MXHTMLToAttributedString's 'imageAttachments' property just after parsing an html string. You don't create instances of this class directly.
 
 Most properties are read-only, except for the width and height properties which you can set to control how large the image is when presented.
*/
@interface MXHTMLImageAttachmentInfo : NSObject

/**
 The string found in the <img> tag's 'src' attribute.
*/
@property (nonatomic, readonly) NSString * src;

/**
 The location in the attributed string where the image will be inserted.
*/
@property (nonatomic, readonly, assign) NSRange location;

/**
 The display width of the image.
 
 If the <img> tag had a valid width= value, it will be stored here.
 
 You can modify this property with your own value to determine the size of the image when it is displayed. For example, you might want to limit the image size based on the size of a text view. By default the image will be displayed at 100%.
 
 If width is set to a value > 0.0 and height = 0.0, then the image width will be limited to the width value, and the height will be based on the image's aspect ratio.
*/
@property (nonatomic, assign) float width;

/**
 The display height of the image.
 
 If the image tag had a valid height= value, it will be stored here.
 
 You can modify this property with your own value to determine the size of the image when it is displayed. For example, you might want to limit the image size based on the size of a text view. By default the image will be displayed at 100%.
 
  If height is set to a value > 0.0 and width = 0.0, then the image height will be limited to the height value, and the width will be based on the image's aspect ratio.
 */
@property (nonatomic, assign) float height;

@property (nonatomic, readonly, nullable) NSDictionary * textAttributes;
@end

NS_ASSUME_NONNULL_END
