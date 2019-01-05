//
//  MXHTMLToAttributedStringDelegateDefault.m
//  UTStatus
//
//  Created by Mike Spears on 2014-10-15.
//  Copyright (c) 2014 samesimilar. All rights reserved.
//

#import "MXHTMLToAttributedStringDelegateDefault.h"


@implementation MXHTMLToAttributedStringDelegateDefault

- (instancetype) init {
    self = [super init];
    if (self) {
        self.lineBreakMode = NSLineBreakByWordWrapping;
        self.bodyFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        self.h1Font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle1];
        self.h2Font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
        self.h3Font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle3];
        self.normalParagraphSpacing = 0;
        self.normalParagraphSpacingBefore = 0;
        self.monospaceFont = [UIFont fontWithName:@"Courier" size:12];
        self.preformattedTextLineBreakMode = NSLineBreakByClipping;
        self.orderedListItemPrefixFormat = @"%ld. ";
        self.unorderedListItemPrefix = @"•  ";
        self.listItemIndentCharacterCount = 4;
    }
    
    return self;
}
- (NSDictionary *) initialAttributes
{
    UIFont *bodyfont = self.bodyFont;
    NSMutableParagraphStyle * ps = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    ps.paragraphSpacing = self.normalParagraphSpacing;
    ps.paragraphSpacingBefore = self.normalParagraphSpacingBefore;
    ps.lineBreakMode = self.lineBreakMode;
    
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
        UIFontDescriptor * newDescriptor = [descriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold | descriptor.symbolicTraits];
        
        newAttrs[NSFontAttributeName] = [UIFont fontWithDescriptor:newDescriptor size:oldFont.pointSize];
        
    } else if ([tag isEqualToString:@"em"] || [tag isEqualToString:@"i"]) {
        UIFont * oldFont = currentAttrs[NSFontAttributeName];
        UIFontDescriptor * descriptor = [oldFont fontDescriptor];
        UIFontDescriptor * newDescriptor = [descriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic | descriptor.symbolicTraits] ;
        
        newAttrs[NSFontAttributeName] = [UIFont fontWithDescriptor:newDescriptor size:oldFont.pointSize];
        
    } else if ([tag isEqualToString:@"code"] || [tag isEqualToString:@"pre"]) {
        UIFont * oldFont = currentAttrs[NSFontAttributeName];
//        UIFontDescriptor * descriptor = [oldFont fontDescriptor];
//        UIFontDescriptor * newDescriptor = [descriptor fontDescriptorWithFamily:@"Courier"];
        NSMutableParagraphStyle * ps = [currentAttrs[NSParagraphStyleAttributeName] mutableCopy];
        // don't wrap lines for preformatted text
        ps.lineBreakMode = NSLineBreakByClipping;
        
        
        
        newAttrs[NSFontAttributeName] = [self.monospaceFont fontWithSize:oldFont.pointSize];
        newAttrs[NSParagraphStyleAttributeName] = ps;
        //        newAttrs[NSBackgroundColorAttributeName] = [UIColor blackColor];
        //        newAttrs[NSForegroundColorAttributeName] = [UIColor whiteColor];
        
    } else if ([tag isEqualToString:@"h1"]) {
        UIFont * oldFont = currentAttrs[NSFontAttributeName];
        UIFontDescriptor * descriptor = [oldFont fontDescriptor];
        UIFont * headerFont = self.h1Font;
        UIFontDescriptor * headerDescriptor = [[headerFont fontDescriptor] fontDescriptorWithSymbolicTraits:descriptor.symbolicTraits];
        newAttrs[NSFontAttributeName] = [UIFont fontWithDescriptor:headerDescriptor size:headerFont.pointSize];
    } else if ([tag isEqualToString:@"h2"]) {
//        newAttrs[NSFontAttributeName] = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
        UIFont * oldFont = currentAttrs[NSFontAttributeName];
        UIFontDescriptor * descriptor = [oldFont fontDescriptor];
        UIFont * headerFont = self.h2Font;
        UIFontDescriptor * headerDescriptor = [[headerFont fontDescriptor] fontDescriptorWithSymbolicTraits:descriptor.symbolicTraits];
        newAttrs[NSFontAttributeName] = [UIFont fontWithDescriptor:headerDescriptor size:headerFont.pointSize];

    } else if ([tag isEqualToString:@"h3"] || [tag isEqualToString:@"h4"]) {
//        newAttrs[NSFontAttributeName] = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle3];
        UIFont * oldFont = currentAttrs[NSFontAttributeName];
        UIFontDescriptor * descriptor = [oldFont fontDescriptor];
        UIFont * headerFont = self.h3Font;
        UIFontDescriptor * headerDescriptor = [[headerFont fontDescriptor] fontDescriptorWithSymbolicTraits:descriptor.symbolicTraits];
        newAttrs[NSFontAttributeName] = [UIFont fontWithDescriptor:headerDescriptor size:headerFont.pointSize];

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

- (NSDictionary *) attributesForOrderedListRemainingParagraphsAtLevel:(NSInteger) level currentAttributes:(NSDictionary *) currentAttrs {
    return [self attributesForUnorderedListRemainingParagraphsAtLevel:level currentAttributes:currentAttrs];
}

- (NSString *) textForOrderedListItemIndex:(NSInteger) index atListLevel:(NSInteger) level
{
    return [NSString stringWithFormat:self.orderedListItemPrefixFormat, (long)index];
}

- (NSDictionary *) attributesForUnorderedListLevel:(NSInteger) level currentAttributes:(NSDictionary *) currentAttrs
{
    NSMutableDictionary * newAttrs = [currentAttrs mutableCopy];
    
    UIFont  * font = newAttrs[NSFontAttributeName];
    
    CGSize charSize = [@" " sizeWithAttributes:@{NSFontAttributeName: font}];
    
    
    
    
    NSMutableParagraphStyle * ps = [currentAttrs[NSParagraphStyleAttributeName] mutableCopy];
    ps.firstLineHeadIndent = charSize.width * (level * self.listItemIndentCharacterCount);
    ps.headIndent = charSize.width * ((level + 1) * self.listItemIndentCharacterCount);
    
    
    
    ps.defaultTabInterval = charSize.width * self.listItemIndentCharacterCount;
    
    newAttrs[NSParagraphStyleAttributeName] = ps;
    return newAttrs;
}

- (NSDictionary *) attributesForUnorderedListRemainingParagraphsAtLevel:(NSInteger) level currentAttributes:(NSDictionary *) currentAttrs
{
    NSMutableDictionary * newAttrs = [currentAttrs mutableCopy];
    
    UIFont  * font = newAttrs[NSFontAttributeName];
    
    CGSize charSize = [@" " sizeWithAttributes:@{NSFontAttributeName: font}];
    
    
    
    
    NSMutableParagraphStyle * ps = [currentAttrs[NSParagraphStyleAttributeName] mutableCopy];
    ps.firstLineHeadIndent = ps.headIndent;
    
    
    
    
    ps.defaultTabInterval = charSize.width * self.listItemIndentCharacterCount;
    
    newAttrs[NSParagraphStyleAttributeName] = ps;
    return newAttrs;
}

- (NSString *) textForUnorderedListItemAtListLevel:(NSInteger) level
{
    return self.unorderedListItemPrefix;
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
