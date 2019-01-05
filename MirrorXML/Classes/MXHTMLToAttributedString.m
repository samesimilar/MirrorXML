//
//  MXHTMLToAttributedString.m
//  UTStatus
//
//  Created by Mike Spears on 2014-10-14.
//  Copyright (c) 2014 samesimilar. All rights reserved.
//

#import "MXHTMLToAttributedString.h"
#import <AVFoundation/AVFoundation.h>

#import "MirrorXML.h"
#import "MXHTMLToAttributedStringDelegateDefault.h"


@interface MXHTMLToAttributedString ()
@property (nonatomic) id <MXHTMLToAttributedStringDelegate> defaultDelegate;
@property (nonatomic) NSArray * imageSources;
@end
@implementation MXHTMLToAttributedString


- (id) init
{
    self = [super init];
    if (self) {
        self.defaultDelegate = [[MXHTMLToAttributedStringDelegateDefault alloc] init];
        self.delegate = self.defaultDelegate;
    }
    return self;
}

- (NSMutableAttributedString *) convertHTMLString:(NSString *) html
{
    __block int ignoreText = 0;
    __block int preformattedTextFlag = 0;
    
    __block NSDictionary *attrsDictionary = [NSMutableDictionary new];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] init];
    
    attrsDictionary = [self.delegate initialAttributes];
    
//    MXHTMLParser * mp = [[MXHTMLParser alloc] init];
//    MXHandlerList * ml = [[MXHandlerList alloc] init];
    
    
    MXMatch *errorHandler = [[MXMatch alloc] initWithPath:@"//*" namespaces:nil error: nil];
    
    __block NSString * errorPath = @"/";
//    __block NSInteger counter = 0;
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
        NSLog(@"HTML Parse error: %@ Path: %@", error.localizedDescription, errorPath);
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
//
//        NSMutableCharacterSet * c;
//        c = [NSMutableC haracterSet characterSetWithCharactersInString:@",.:;?!"];
        
//        if (mainText.length > 0 && ![mainText hasSuffix:@"\n"] && t.length > 0 && ([t rangeOfCharacterFromSet:c options:0 range:NSMakeRange(0, 1)].location == NSNotFound)) {
//            t = [@" " stringByAppendingString:t];
//        }
        
        
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
        NSString * mainText = attrString.string;
//        if (![mainText hasSuffix:@"\n"]) {
            NSAttributedString * str = [[NSAttributedString alloc] initWithString:@"\n" attributes:attrsDictionary];
            [attrString appendAttributedString:str];
//        }
        
        return nil;
    };
    
    MXMatch * p = [[MXMatch alloc] initWithPath:@"//p" namespaces:nil error:nil];
    p.entryHandler = (id)^(MXElement *br) {
        [self addNewParagraphToString:attrString attributes:attrsDictionary];
        return nil;
        
    };
    p.exitHandler = ^(MXElement *br) {
        [self addNewParagraphToString:attrString attributes:attrsDictionary];
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
//            if (elm.userInfo) return @[];
//            id liObject = [NSObject new];
//            elm.userInfo = liObject;
            
            NSDictionary *oldDict = attrsDictionary;
            attrsDictionary = [self.delegate attributesForOrderedListLevel:listLevel currentAttributes:oldDict];
            
            listCount++;
            
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
            
//            if (elm.userInfo) return @[];
//            id liObject = [NSObject new];
//            elm.userInfo = liObject;
            
            
            
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
        NSTextAttachment * ta = [[NSTextAttachment alloc] initWithData:nil ofType:nil];
        if (elm.attributes[@"src"]) {
            [imgSrc addObject:elm.attributes[@"src"]];
            ta.image = [UIImage imageNamed:@"IMG_0176.jpg"]; 
            ta.bounds = CGRectMake(0, 0, 200, ta.image.size.height * (200 / ta.image.size.width));
            
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init] ;
            
            [paragraphStyle setAlignment:NSTextAlignmentCenter];            // centers image horizontally
            
            [paragraphStyle setParagraphSpacing:5];   // adds some padding between the image and the following section
            NSMutableAttributedString * taStr = [[NSAttributedString attributedStringWithAttachment:ta] mutableCopy];
            [taStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, taStr.length)];
            
            [self addNewParagraphToString:attrString attributes:attrsDictionary];
            [attrString appendAttributedString:taStr];
            [self addNewParagraphToString:attrString attributes:attrsDictionary];
        }
        

        
        return nil;
                                                    
    };
    
    NSArray * handlers = @[textHandler, script, br, p, tags1, tags2, ol, ul, a, img, pre];
    
#ifdef DEBUG
    handlers = [handlers arrayByAddingObject:errorHandler];
#endif
    
//    html = [html stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    MXHTMLParser *parser = [[MXHTMLParser alloc] initWithMatches:handlers];
    [parser parseDataChunk:[html dataUsingEncoding:NSUTF8StringEncoding]];
    [parser dataFinished];

    self.imageSources = imgSrc;
    
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

//    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
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
