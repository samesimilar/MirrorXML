//
//  MXHTMLImageAttachmentInfo.h
//  Pods
//
//  Created by Mike Spears on 2019-01-04.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MXHTMLImageAttachmentInfo : NSObject
@property (nonatomic, readonly) NSString * src;
@property (nonatomic, readonly, assign) NSRange location;
@property (nonatomic, assign) float width;
@property (nonatomic, assign) float height;
@property (nonatomic, readonly, nullable) NSDictionary * textAttributes;
@end

NS_ASSUME_NONNULL_END
