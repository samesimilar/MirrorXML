//
//  MXHTMLToAttributedStringDelegateDefault.m
//  UTStatus
//
//  Created by Mike Spears on 2014-10-15.
//  Copyright (c) 2014 samesimilar. All rights reserved.
//

#import "MXHTMLToAttributedStringDelegateDefault.h"

@implementation MXHTMLToAttributedStringDelegateDefault

- (NSDictionary *) initialAttributes
{
    UIFont *bodyfont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    NSMutableParagraphStyle * ps = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    ps.paragraphSpacing = 2;
    
    return @{NSFontAttributeName: bodyfont, NSParagraphStyleAttributeName: ps};
}

- (NSDictionary *) attributesForTag:(NSString *) tag currentAttributes:(NSDictionary *) currentAttrs
{
    NSMutableDictionary * newAttrs = [currentAttrs mutableCopy];
    
    if ([tag isEqualToString:@"small"]) {
        UIFont * oldFont = currentAttrs[NSFontAttributeName];
        newAttrs[NSFontAttributeName] = [oldFont fontWithSize:oldFont.pointSize * 0.75];
    } else if ([tag isEqualToString:@"strong"] || [tag isEqualToString:@"b"]) {
        UIFont * oldFont = currentAttrs[NSFontAttributeName];
        UIFontDescriptor * descriptor = [oldFont fontDescriptor];
        UIFontDescriptor * newDescriptor = [descriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
        
        newAttrs[NSFontAttributeName] = [UIFont fontWithDescriptor:newDescriptor size:oldFont.pointSize];
        
    } else if ([tag isEqualToString:@"em"] || [tag isEqualToString:@"i"]) {
        UIFont * oldFont = currentAttrs[NSFontAttributeName];
        UIFontDescriptor * descriptor = [oldFont fontDescriptor];
        UIFontDescriptor * newDescriptor = [descriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic];
        
        newAttrs[NSFontAttributeName] = [UIFont fontWithDescriptor:newDescriptor size:oldFont.pointSize];
        
    } else if ([tag isEqualToString:@"code"]) {
        UIFont * oldFont = currentAttrs[NSFontAttributeName];
        UIFontDescriptor * descriptor = [oldFont fontDescriptor];
        UIFontDescriptor * newDescriptor = [descriptor fontDescriptorWithFamily:@"Courier"];
        
        newAttrs[NSFontAttributeName] = [UIFont fontWithDescriptor:newDescriptor size:oldFont.pointSize];
        //        newAttrs[NSBackgroundColorAttributeName] = [UIColor blackColor];
        //        newAttrs[NSForegroundColorAttributeName] = [UIColor whiteColor];
        
    } else if ([tag isEqualToString:@"h1"]) {
        newAttrs[NSFontAttributeName] = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle1];
    } else if ([tag isEqualToString:@"h2"]) {
        newAttrs[NSFontAttributeName] = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
    } else if ([tag isEqualToString:@"h3"] || [tag isEqualToString:@"h4"]) {
        newAttrs[NSFontAttributeName] = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle3];
    }
    
    
    return newAttrs;
}
- (NSDictionary *) attributesForOrderedListLevel:(NSInteger) level currentAttributes:(NSDictionary *) currentAttrs
{
    
    return [self attributesForUnorderedListLevel:level currentAttributes:currentAttrs];
    //    NSMutableDictionary * newAttrs = [currentAttrs mutableCopy];
    //
    //    UIFont  * font = newAttrs[NSFontAttributeName];
    //    CGFloat fontSize = font.pointSize;
    //
    //    NSMutableParagraphStyle * ps = [currentAttrs[NSParagraphStyleAttributeName] mutableCopy];
    //    ps.headIndent = fontSize * 3 * level;
    //    ps.firstLineHeadIndent = fontSize * level;
    //    NSTextTab * tab = [[NSTextTab alloc] initWithTextAlignment:NSTextAlignmentNatural
    //                                                      location:fontSize * 3
    //                                                       options:nil];
    //    ps.tabStops = @[tab];
    //    newAttrs[NSParagraphStyleAttributeName] = ps;
    //    return newAttrs;
    
}

- (NSString *) textForOrderedListItemIndex:(NSInteger) index atListLevel:(NSInteger) level
{
    return [NSString stringWithFormat:@"%ld.\t", (long)index];
}

- (NSDictionary *) attributesForUnorderedListLevel:(NSInteger) level currentAttributes:(NSDictionary *) currentAttrs
{
    NSMutableDictionary * newAttrs = [currentAttrs mutableCopy];
    
    UIFont  * font = newAttrs[NSFontAttributeName];
    
    CGSize charSize = [@" " sizeWithAttributes:@{NSFontAttributeName: font}];
    
    
    
    
    NSMutableParagraphStyle * ps = [currentAttrs[NSParagraphStyleAttributeName] mutableCopy];
    ps.firstLineHeadIndent =charSize.width * 3 * level;
    ps.headIndent = charSize.width * 9 * level;
    
    
    
    ps.defaultTabInterval = charSize.width * 3;
    
    newAttrs[NSParagraphStyleAttributeName] = ps;
    return newAttrs;
}

- (NSString *) textForUnorderedListItemAtListLevel:(NSInteger) level
{
    return @"•\t";
}
- (NSDictionary *) attributesForAnchorElementWithHTMLAttributes:(NSDictionary *) htmlAttributes currentTextAttributes:(NSDictionary *) currentAttrs
{
    NSMutableDictionary * newAttrs = [currentAttrs mutableCopy];
    
    if (htmlAttributes[@"href"]) {
        newAttrs[NSLinkAttributeName] = [NSURL URLWithString:htmlAttributes[@"href"]];
    }
    
    return newAttrs;
    
}



@end
