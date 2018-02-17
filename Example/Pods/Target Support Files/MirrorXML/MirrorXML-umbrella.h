#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "MirrorXML.h"
#import "MXElement.h"
#import "MXHTMLParser.h"
#import "MXHTMLToAttributedString.h"
#import "MXHTMLToAttributedStringDelegateDefault.h"
#import "MXMatch.h"
#import "MXMatchList.h"
#import "MXParser.h"
#import "MXPattern.h"
#import "MXPatternStream.h"
#import "MXTextElement.h"

FOUNDATION_EXPORT double MirrorXMLVersionNumber;
FOUNDATION_EXPORT const unsigned char MirrorXMLVersionString[];

