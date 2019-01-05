//
//  MXHTMLImageAttachmentInfo.h
//  Pods
//
//  Created by Mike Spears on 2019-01-04.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MXHTMLImageAttachmentInfo : NSObject
@property (nonatomic, readonly) NSString * src;
@property (nonatomic, readonly, assign) NSRange location;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, readonly, nullable) NSDictionary * textAttributes;
@end

NS_ASSUME_NONNULL_END
