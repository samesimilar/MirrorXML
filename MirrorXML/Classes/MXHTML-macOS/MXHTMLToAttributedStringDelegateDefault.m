//
//  MXHTMLToAttributedStringDelegateDefault.m
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
#import "MXHTMLToAttributedStringDelegateDefault.h"


@implementation MXHTMLToAttributedStringDelegateDefault

- (instancetype) init {
    self = [super init];
    if (self) {
        self.lineBreakMode = NSLineBreakByWordWrapping;
        self.bodyFont = [NSFont fontWithName:@"SF UI Text" size:17.0];
        self.h1Font = [NSFont fontWithName:@"SF UI Display" size:28.0];
        self.h2Font = [NSFont fontWithName:@"SF UI Display" size:22.0];
        self.h3Font = [NSFont fontWithName:@"SF UI Display" size:20.0];
        self.normalParagraphSpacing = 0;
        self.normalParagraphSpacingBefore = 0;
        self.monospaceFont = [NSFont fontWithName:@"Courier" size:12];
        self.preformattedTextLineBreakMode = NSLineBreakByClipping;
        self.orderedListItemPrefixFormat = @"%ld.  ";
        self.unorderedListItemPrefix = @"•  ";
        self.listItemIndentCharacterCount = 4;
    }
    
    return self;
}
- (NSDictionary *) initialAttributes
{
    NSFont *bodyfont = self.bodyFont;
    NSMutableParagraphStyle * ps = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    ps.paragraphSpacing = self.normalParagraphSpacing;
    ps.paragraphSpacingBefore = self.normalParagraphSpacingBefore;
    ps.lineBreakMode = self.lineBreakMode;
    
    return @{NSFontAttributeName: bodyfont, NSParagraphStyleAttributeName: ps};
}

- (NSDictionary<NSAttributedStringKey, id> *) attributesForTag:(NSString *) tag currentAttributes:(NSDictionary<NSAttributedStringKey, id> *) currentAttrs
{
    NSMutableDictionary * newAttrs = [currentAttrs mutableCopy];
    
    if ([tag isEqualToString:@"small"]) {
        NSFont * oldFont = currentAttrs[NSFontAttributeName];
        NSFontDescriptor * descriptor = [oldFont fontDescriptor];
        
        newAttrs[NSFontAttributeName] = [NSFont fontWithDescriptor:descriptor size:oldFont.pointSize * 0.75];
    } else if ([tag isEqualToString:@"strong"] || [tag isEqualToString:@"b"]) {
        NSFont * oldFont = currentAttrs[NSFontAttributeName];
        NSFontDescriptor * descriptor = [oldFont fontDescriptor];
        NSFontDescriptor * newDescriptor = [descriptor fontDescriptorWithSymbolicTraits:NSFontDescriptorTraitBold | descriptor.symbolicTraits];
        
        newAttrs[NSFontAttributeName] = [NSFont fontWithDescriptor:newDescriptor size:oldFont.pointSize];
        
    } else if ([tag isEqualToString:@"em"] || [tag isEqualToString:@"i"]) {
        NSFont * oldFont = currentAttrs[NSFontAttributeName];
        NSFontDescriptor * descriptor = [oldFont fontDescriptor];
        NSFontDescriptor * newDescriptor = [descriptor fontDescriptorWithSymbolicTraits:NSFontDescriptorTraitItalic | descriptor.symbolicTraits] ;
        
        newAttrs[NSFontAttributeName] = [NSFont fontWithDescriptor:newDescriptor size:oldFont.pointSize];
        
    } else if ([tag isEqualToString:@"code"] || [tag isEqualToString:@"pre"]) {
        NSFont * oldFont = currentAttrs[NSFontAttributeName];
        NSMutableParagraphStyle * ps = [currentAttrs[NSParagraphStyleAttributeName] mutableCopy];
        // don't wrap lines for preformatted text
        ps.lineBreakMode = NSLineBreakByClipping;
        
        NSFontDescriptor * monospaceDescriptor = [self.monospaceFont fontDescriptor];
        
        newAttrs[NSFontAttributeName] = [NSFont fontWithDescriptor:monospaceDescriptor size:oldFont.pointSize];
        newAttrs[NSParagraphStyleAttributeName] = ps;
    } else if ([tag isEqualToString:@"h1"]) {
        NSFont * oldFont = currentAttrs[NSFontAttributeName];
        NSFontDescriptor * descriptor = [oldFont fontDescriptor];
        NSFont * headerFont = self.h1Font;
        NSFontDescriptor * headerDescriptor = [[headerFont fontDescriptor] fontDescriptorWithSymbolicTraits:descriptor.symbolicTraits];
        newAttrs[NSFontAttributeName] = [NSFont fontWithDescriptor:headerDescriptor size:headerFont.pointSize];
    } else if ([tag isEqualToString:@"h2"]) {
        NSFont * oldFont = currentAttrs[NSFontAttributeName];
        NSFontDescriptor * descriptor = [oldFont fontDescriptor];
        NSFont * headerFont = self.h2Font;
        NSFontDescriptor * headerDescriptor = [[headerFont fontDescriptor] fontDescriptorWithSymbolicTraits:descriptor.symbolicTraits];
        newAttrs[NSFontAttributeName] = [NSFont fontWithDescriptor:headerDescriptor size:headerFont.pointSize];

    } else if ([tag isEqualToString:@"h3"] || [tag isEqualToString:@"h4"]) {
        NSFont * oldFont = currentAttrs[NSFontAttributeName];
        NSFontDescriptor * descriptor = [oldFont fontDescriptor];
        NSFont * headerFont = self.h3Font;
        NSFontDescriptor * headerDescriptor = [[headerFont fontDescriptor] fontDescriptorWithSymbolicTraits:descriptor.symbolicTraits];
        newAttrs[NSFontAttributeName] = [NSFont fontWithDescriptor:headerDescriptor size:headerFont.pointSize];

    }
    
    
    return newAttrs;
}
- (NSDictionary<NSAttributedStringKey, id> *) attributesForOrderedListLevel:(NSInteger) level itemIndex:(NSInteger) index currentAttributes:(NSDictionary<NSAttributedStringKey, id> *) currentAttrs
{
    NSMutableDictionary * newAttrs = [currentAttrs mutableCopy];
    
    NSFont  * font = newAttrs[NSFontAttributeName];
    
    CGSize charSize = [@" " sizeWithAttributes:@{NSFontAttributeName: font}];
    
    
    
    
    NSMutableParagraphStyle * ps = [currentAttrs[NSParagraphStyleAttributeName] mutableCopy];
    ps.firstLineHeadIndent = ps.firstLineHeadIndent + charSize.width * self.listItemIndentCharacterCount;
    ps.headIndent = ps.firstLineHeadIndent + [[self textForOrderedListItemIndex:index atListLevel:level] sizeWithAttributes:@{NSFontAttributeName: font}].width;
    newAttrs[NSParagraphStyleAttributeName] = ps;
    return newAttrs;
    
}

- (NSDictionary<NSAttributedStringKey, id> *) attributesForOrderedListRemainingParagraphsAtLevel:(NSInteger) level currentAttributes:(NSDictionary<NSAttributedStringKey, id> *) currentAttrs {
    return [self attributesForUnorderedListRemainingParagraphsAtLevel:level currentAttributes:currentAttrs];
}

- (NSString *) textForOrderedListItemIndex:(NSInteger) index atListLevel:(NSInteger) level
{
    return [NSString stringWithFormat:self.orderedListItemPrefixFormat, (long)index];
}

- (NSDictionary<NSAttributedStringKey, id> *) attributesForUnorderedListLevel:(NSInteger) level currentAttributes:(NSDictionary<NSAttributedStringKey, id> *) currentAttrs
{
    NSMutableDictionary * newAttrs = [currentAttrs mutableCopy];
    
    NSFont  * font = newAttrs[NSFontAttributeName];
    
    CGSize charSize = [@" " sizeWithAttributes:@{NSFontAttributeName: font}];
    NSMutableParagraphStyle * ps = [currentAttrs[NSParagraphStyleAttributeName] mutableCopy];
    ps.firstLineHeadIndent = ps.firstLineHeadIndent + charSize.width * self.listItemIndentCharacterCount;
    ps.headIndent = ps.firstLineHeadIndent + [[self textForUnorderedListItemAtListLevel:level] sizeWithAttributes:@{NSFontAttributeName: font}].width;
    newAttrs[NSParagraphStyleAttributeName] = ps;
    return newAttrs;
}

- (NSDictionary<NSAttributedStringKey, id> *) attributesForUnorderedListRemainingParagraphsAtLevel:(NSInteger) level currentAttributes:(NSDictionary<NSAttributedStringKey, id> *) currentAttrs
{
    NSMutableDictionary * newAttrs = [currentAttrs mutableCopy];
    
    NSMutableParagraphStyle * ps = [currentAttrs[NSParagraphStyleAttributeName] mutableCopy];
    ps.firstLineHeadIndent = ps.headIndent;
    
    
    newAttrs[NSParagraphStyleAttributeName] = ps;
    return newAttrs;
}

- (NSString *) textForUnorderedListItemAtListLevel:(NSInteger) level
{
    return self.unorderedListItemPrefix;
}
- (NSDictionary<NSAttributedStringKey, id> *) attributesForAnchorElementWithHTMLAttributes:(NSDictionary<NSString *, NSString *> *) htmlAttributes currentTextAttributes:(NSDictionary<NSAttributedStringKey, id> *) currentAttrs
{
    NSMutableDictionary * newAttrs = [currentAttrs mutableCopy];
    
    if (htmlAttributes[@"href"]) {
        newAttrs[NSLinkAttributeName] = [NSURL URLWithString:htmlAttributes[@"href"]];
    }
    
    return newAttrs;
    
}





@end
