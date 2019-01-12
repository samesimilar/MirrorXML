//
//  MXHTMLImageAttachmentInfo.m
//  Pods
//
//  Created by Mike Spears on 2019-01-04.
//

#import "MXHTMLImageAttachmentInfo.h"

@interface MXHTMLImageAttachmentInfo()
@property (nonatomic, nonnull) NSString * src;
@property (nonatomic, assign) NSRange location;
@property (nonatomic, nullable) NSDictionary * textAttributes;
@end

@implementation MXHTMLImageAttachmentInfo
- (instancetype) init {
    self = [super init];
    if (self) {
        self.width = 0.0;
        self.height = 0.0;
        
    }
    return self;
}
@end
