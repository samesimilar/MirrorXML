//
//  MXHTMLToAttributedString.m
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

#import "MXHTMLToAttributedString.h"
#import "MXMatch.h"
#import "MXElement.h"
#import "MXHTMLParser.h"
#import "MXPattern.h"
#import "MXHTMLToAttributedStringDelegateDefault.h"
#import "MXHTMLImageAttachmentInfo.h"

@interface MXHTMLImageAttachmentInfo()
@property (nonatomic, nonnull) NSString * src;
@property (nonatomic, assign) NSRange location;
@property (nonatomic, nullable) NSDictionary * textAttributes;
@end

@interface MXHTMLToAttributedString ()
@property (nonatomic) id <MXHTMLToAttributedStringDelegate> defaultDelegate;
@property (nonatomic) NSArray<MXHTMLImageAttachmentInfo *>  * imageAttachments;
@property (nonatomic) NSArray<NSError *> * errors;
@end

NSInteger const MXHTMLToAttirbutedStringParseError = 100;

@implementation MXHTMLToAttributedString

+ (void) insertImage:(UIImage *) image withInfo:(MXHTMLImageAttachmentInfo *) info toString:(NSMutableAttributedString *) string {
    
    NSTextAttachment * ta = [[NSTextAttachment alloc] initWithData:nil ofType:nil];
    ta.image = image;
    if (info.width == CGSizeZero.width && info.height == CGSizeZero.height) {
        ta.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    } else if (info.width != CGSizeZero.width && info.height == CGSizeZero.height) {
        ta.bounds = CGRectMake(0, 0, info.width, image.size.height * (info.width / image.size.width));
    } else if (info.width == CGSizeZero.width && info.height != CGSizeZero.height) {
        ta.bounds = CGRectMake(0, 0, image.size.width * (info.height / image.size.height), info.height);
    } else {
        ta.bounds = CGRectMake(0, 0, info.width, info.height);
    }
    NSMutableAttributedString * taStr = [[NSAttributedString attributedStringWithAttachment:ta] mutableCopy];
    
    if (info.textAttributes) {
        [taStr addAttributes:info.textAttributes range:NSMakeRange(0, [taStr length])];
    }

    [string replaceCharactersInRange:info.location withAttributedString:taStr];

}
- (id) init
{
    self = [super init];
    if (self) {
        self.defaultDelegate = [[MXHTMLToAttributedStringDelegateDefault alloc] init];
        self.delegate = self.defaultDelegate;
        self.saveParsingErrors = YES;
        self.errors = nil;
    }
    return self;
}

- (NSMutableAttributedString *) convertHTMLString:(NSString *) html
{
    self.errors = nil;
    __block int ignoreText = 0;
    __block int preformattedTextFlag = 0;
    
    __block NSDictionary *attrsDictionary = [NSMutableDictionary new];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] init];
    
    attrsDictionary = [self.delegate initialAttributes];
    
    NSMutableArray<NSError *> * errorMessages = [NSMutableArray new];
    MXMatch *errorHandler = [[MXMatch alloc] initWithPath:@"//*" namespaces:nil error: nil];
    
    __block NSString * errorPath = @"/";
    __block NSMutableDictionary * counters = [NSMutableDictionary new];
    
    errorHandler.entryHandler = (id)^(MXElement *elm) {
    
        NSNumber * c  = counters[elm.elementName];
        NSInteger n = 1;
        if (!c) {
            counters[elm.elementName] = @1;
        } else {
            n = [c integerValue];
            n++;
            counters[elm.elementName] = @(n);
        }
        
        errorPath = [errorPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@[%@]",elm.elementName, @(n)]];
        
        
        NSMutableDictionary * oldCounters = counters;
        counters = [NSMutableDictionary new];
        MXMatch * h = [MXMatch onRootExit:^(MXElement * elm) {
            counters = oldCounters;
            errorPath = [errorPath stringByDeletingLastPathComponent];

        }];
        
        return @[h];
        
        
    };

    
    errorHandler.errorHandler = ^(NSError * error, MXElement * elm)
    {
        [errorMessages addObject:[[NSError alloc] initWithDomain:MirrorXMLErrorDomain code:MXHTMLToAttirbutedStringParseError userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"HTML Parse error: %@ Path: %@", error.localizedDescription, errorPath]}]];
    };
    
    MXMatch * textHandler = [[MXMatch alloc] initWithPath:@"//*" namespaces:nil error: nil];
    textHandler.textHandler = ^(MXElement *elm) {
        if (ignoreText > 0) return;
        if (preformattedTextFlag > 0) {
            NSAttributedString * str = [[NSAttributedString alloc] initWithString:elm.text attributes:attrsDictionary];
            [attrString appendAttributedString:str];
            return;
        }
        
        NSString * t = [self collapseString:elm.text];
        NSString * mainText = attrString.string;
        if ([mainText hasSuffix:@"\n"] || [mainText hasSuffix:@" "] || [mainText hasSuffix:@"\t"]) {
            t = [t stringByReplacingOccurrencesOfString:@"^[ \t\n]+" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, t.length)];
        }

        NSAttributedString * str = [[NSAttributedString alloc] initWithString:t attributes:attrsDictionary];
        [attrString appendAttributedString:str];
    };
    
    MXMatch * script = [[MXMatch alloc] initWithPath:@"//script|//head" namespaces:nil error:nil];
    script.entryHandler = (id)^(MXElement *elm) {
        ignoreText++;
        return nil;
    };
    script.exitHandler = ^(MXElement *elm) {
        if (ignoreText > 0) ignoreText--;
    };
    
    MXMatch * pre = [[MXMatch alloc] initWithPath:@"//pre" error:nil];
    pre.entryHandler = ^NSArray<MXMatch *> * _Nonnull(MXElement * _Nonnull elm) {
        preformattedTextFlag++;
        NSDictionary *oldDict = attrsDictionary;
        
        attrsDictionary = [self.delegate attributesForTag:elm.elementName currentAttributes:oldDict];
        
        MXMatch * m = [MXMatch onRootExit:^(MXElement * elm) {
            attrsDictionary = oldDict;
            if (preformattedTextFlag > 0) preformattedTextFlag--;
        }];
        
        return  @[m];
        
       
    };
    
    MXMatch * br = [[MXMatch alloc] initWithPath:@"//br" namespaces:nil error:nil];
    br.entryHandler = (id)^(MXElement *br) {
        NSAttributedString * str = [[NSAttributedString alloc] initWithString:@"\n" attributes:attrsDictionary];
        [attrString appendAttributedString:str];
        return nil;
    };
    
    MXMatch * p = [[MXMatch alloc] initWithPath:@"//p" namespaces:nil error:nil];
    p.entryHandler = (id)^(MXElement *elm) {
        
        NSDictionary *oldDict = attrsDictionary;
        NSMutableDictionary * newAttrs = [oldDict mutableCopy];
        NSMutableParagraphStyle * ps = [newAttrs[NSParagraphStyleAttributeName] mutableCopy];
        
        
        NSString * attr = elm.lowercasedAttributes[@"align"];
        if (attr) {
            attr = [attr lowercaseString];
            if ([attr isEqualToString:@"center"]) {
                ps.alignment = NSTextAlignmentCenter;
            } else if ([attr isEqualToString:@"left"]) {
                ps.alignment = NSTextAlignmentLeft;
            } else if ([attr isEqualToString:@"right"]) {
                ps.alignment = NSTextAlignmentRight;
            } else if ([attr isEqualToString:@"justify"]) {
                ps.alignment = NSTextAlignmentJustified;
            }
        }
        newAttrs[NSParagraphStyleAttributeName] = ps;
        attrsDictionary = newAttrs;
        
        [self addNewParagraphToString:attrString attributes:attrsDictionary];
        
        MXMatch *m = [MXMatch onRootExit:^(MXElement * _Nonnull elm) {
            [self addNewParagraphToString:attrString attributes:attrsDictionary];
            attrsDictionary = oldDict;
        }];
        return @[m];
        
    };

    
    MXMatch * tags1 = [[MXMatch alloc] initWithPath:@"//small|//strong|//b|//em|//i|//code" namespaces:nil error:nil];
    tags1.entryHandler = (id)^(MXElement *elm) {
        NSDictionary *oldDict = attrsDictionary;
        
        attrsDictionary = [self.delegate attributesForTag:elm.elementName currentAttributes:oldDict];
        
        MXMatch * m = [MXMatch onRootExit:^(MXElement * elm) {
            attrsDictionary = oldDict;
        }];
        
        return  @[m];
        
    };
    
    MXMatch * tags2 = [[MXMatch alloc] initWithPath:@"//h1|//h2|//h3" namespaces:nil error:nil];
    tags2.entryHandler = (id)^(MXElement *elm) {
        
        [self addNewParagraphToString:attrString attributes:attrsDictionary];
        
        NSDictionary *oldDict = attrsDictionary;

        attrsDictionary = [self.delegate attributesForTag:elm.elementName currentAttributes:oldDict];
        
        MXMatch * m = [MXMatch onRootExit:^(MXElement * elm) {
            attrsDictionary = oldDict;
            NSAttributedString * str = [[NSAttributedString alloc] initWithString:@"\n" attributes:attrsDictionary];
            [attrString appendAttributedString:str];
        }];

        return  @[m];
    };
    
    __block NSInteger listLevel = 0;
    
    MXMatch * ol = [[MXMatch alloc] initWithPath:@"//ol" namespaces:nil error:nil];
    ol.entryHandler = (id) ^(MXElement *elm) {
        __block int listCount = 0;
        listLevel++;
        
        MXMatch * li = [[MXMatch alloc] initWithPath:@"/li" namespaces:nil error:nil];
        li.entryHandler = (id) ^(MXElement *elm) {

            listCount++;
            
            NSDictionary *oldDict = attrsDictionary;
            attrsDictionary = [self.delegate attributesForOrderedListLevel:listLevel itemIndex: listCount currentAttributes:oldDict];
            
            
            
            NSString * number = [self.delegate textForOrderedListItemIndex:listCount atListLevel:listLevel];
            NSString * mainText = [attrString string];
            NSString * text = [NSString stringWithFormat:@"%@", number];
            if (![mainText hasSuffix:@"\n"]) {
                text = [@"\n" stringByAppendingString:text];
            }
            
            
            
            
            NSAttributedString * str = [[NSAttributedString alloc] initWithString:text attributes:attrsDictionary];
            [attrString appendAttributedString:str];
            
            attrsDictionary = [self.delegate attributesForOrderedListRemainingParagraphsAtLevel:listLevel currentAttributes:attrsDictionary];
            
            MXMatch * m = [MXMatch onRootExit:^(MXElement * elm) {
                attrsDictionary = oldDict;
            }];

            return @[m];
            
        };
        
        return @[li];
        
    };
    
    ol.exitHandler = ^(MXElement *br) {
        if (listLevel > 0) listLevel--;
    };
    

    
    MXMatch * ul = [[MXMatch alloc] initWithPath:@"//ul" namespaces:nil error:nil];
    ul.entryHandler = (id) ^(MXElement *elm) {
        
        listLevel++;
        
        MXMatch * li = [[MXMatch alloc] initWithPath:@"/li" namespaces:nil error:nil];

        li.entryHandler = (id) ^(MXElement *elm) {

            NSDictionary *oldDict = attrsDictionary;
            attrsDictionary = [self.delegate attributesForUnorderedListLevel:listLevel currentAttributes:oldDict];
            
            
            NSString * text = [self.delegate textForUnorderedListItemAtListLevel:listLevel];
            NSString * mainText = [attrString string];
            if (![mainText hasSuffix:@"\n"]) {
                text = [NSString stringWithFormat:@"\n%@", text];
            }
            
            
            NSAttributedString * str = [[NSAttributedString alloc] initWithString:text attributes:attrsDictionary];
            [attrString appendAttributedString:str];
            
            attrsDictionary = [self.delegate attributesForUnorderedListRemainingParagraphsAtLevel:listLevel currentAttributes:attrsDictionary];
            
            MXMatch * m = [MXMatch onRootExit:^(MXElement * elm) {
                attrsDictionary = oldDict;
            }];

            return @[m];
            
        };
        
        return @[li];
        
    };
    ul.exitHandler = ^(MXElement *elm) {
        if (listLevel > 0) listLevel--;
    };
    
    MXMatch * a = [[MXMatch alloc] initWithPath:@"//a" namespaces:nil error:nil];

    a.entryHandler = (id) ^(MXElement *elm) {
        if (elm.attributes[@"href"]) {
            NSDictionary *oldDict = attrsDictionary;

            attrsDictionary = [self.delegate attributesForAnchorElementWithHTMLAttributes:elm.attributes currentTextAttributes:oldDict];
            
            MXMatch * m = [MXMatch onRootExit:^(MXElement * elm) {
                attrsDictionary = oldDict;
            }];

            return @[m];
        }
        return @[];
    };
    
    MXMatch * img = [[MXMatch alloc] initWithPath:@"//img" namespaces:nil error:nil];
    NSMutableArray * imgSrc = [NSMutableArray new];
    
    img.entryHandler = (id) ^(MXElement *elm) {

        NSString * attr = elm.lowercasedAttributes[@"src"];
        if (!attr) {
            return nil;
        }
        MXHTMLImageAttachmentInfo * info = [[MXHTMLImageAttachmentInfo alloc] init];
        info.src = attr;
        
        attr = elm.lowercasedAttributes[@"width"];
        if (attr) {
            NSScanner * scanner = [[NSScanner alloc] initWithString:attr];
            float width = 0.0;
            if ([scanner scanFloat:&width]) {
                info.width = width;
            }
        }
        attr = elm.lowercasedAttributes[@"height"];
        if (attr) {
            NSScanner * scanner = [[NSScanner alloc] initWithString:attr];
            float height = 0.0;
            if ([scanner scanFloat:&height]) {
                info.height = height;
            }
        }
        
        
        NSAttributedString * placeholder = [[NSAttributedString alloc] initWithString:@"<img>" attributes:attrsDictionary];
        
        info.location = NSMakeRange([attrString length], [placeholder length]);
        info.textAttributes = attrsDictionary;
        [attrString appendAttributedString:placeholder];
        
        [imgSrc addObject:info];


        
        return nil;
                                                    
    };
    
    NSArray * handlers = @[textHandler, script, br, p, tags1, tags2, ol, ul, a, img, pre];

    if (self.saveParsingErrors) {
        handlers = [handlers arrayByAddingObject:errorHandler];
    }
    
    MXHTMLParser *parser = [[MXHTMLParser alloc] initWithMatches:handlers];
    [parser parseDataChunk:[html dataUsingEncoding:NSUTF8StringEncoding]];
    [parser dataFinished];

    self.imageAttachments = imgSrc;
    
    if (self.saveParsingErrors && errorMessages.count > 0) {
        self.errors = errorMessages;
    }
    
    return attrString;
}

- (NSString *) collapseString:(NSString *) str
{

    str = [str stringByReplacingOccurrencesOfString:@"\\n+" withString:@" "
                                            options:NSRegularExpressionSearch range:NSMakeRange(0, str.length)];
    str = [str stringByReplacingOccurrencesOfString:@"\\r+" withString:@" "
                                            options:NSRegularExpressionSearch range:NSMakeRange(0, str.length)];
    str = [str stringByReplacingOccurrencesOfString:@" +"
                                         withString:@" "
                                            options:NSRegularExpressionSearch
                                              range:NSMakeRange(0, str.length)];
    str = [str stringByReplacingOccurrencesOfString:@"\\t+" withString:@"\t"
                                            options:NSRegularExpressionSearch range:NSMakeRange(0, str.length)];

    return str;

}

- (void) addNewParagraphToString:(NSMutableAttributedString *) attrString attributes:(NSDictionary *) attrsDictionary
{
    NSString * mainText = attrString.string;
    if (mainText.length == 0) return;
    if ([mainText hasSuffix:@"\n\n"]) {
        return ;
    }
    if ([mainText hasSuffix:@"\n"]) {
        NSAttributedString * str = [[NSAttributedString alloc] initWithString:@"\n" attributes:attrsDictionary];
        [attrString appendAttributedString:str];
        return ;
    }
    NSAttributedString * str = [[NSAttributedString alloc] initWithString:@"\n\n" attributes:attrsDictionary];
    [attrString appendAttributedString:str];
    return ;
    
}

@end
