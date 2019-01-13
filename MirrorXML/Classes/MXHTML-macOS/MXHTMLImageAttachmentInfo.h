//
//  MXHTMLImageAttachmentInfo.h
//  Pods
//
//  Created by Mike Spears on 2019-01-04.
//

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
 
 If the <img> tag had a valid height= value, it will be stored here.
 
 You can modify this property with your own value to determine the size of the image when it is displayed. For example, you might want to limit the image size based on the size of a text view. By default the image will be displayed at 100%.
 
 If height is set to a value > 0.0 and width = 0.0, then the image height will be limited to the height value, and the width will be based on the image's aspect ratio.
 */
@property (nonatomic, assign) float height;

@property (nonatomic, readonly, nullable) NSDictionary * textAttributes;
@end

NS_ASSUME_NONNULL_END
