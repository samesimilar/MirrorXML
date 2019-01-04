//
//  MXHTMLParserContext.m
//  MirrorXML
//
//  Created by Mike Spears on 2014-04-23.
//  Copyright (c) 2014 samesimilar. All rights reserved.
//

#import <libxml/tree.h>
#import <libxml/HTMLparser.h>

#import "MXHTMLParser.h"
#import "MXMatchList.h"
#import "MXElement.h"
#import "MXAttributeElement.h"
#import "MXTextElement.h"

static xmlSAXHandler simpleHTMLSAXHandlerStruct;

@interface MXElement ()

@property (nonatomic, assign) const xmlChar *xmlLocalname;
@property (nonatomic, assign) const xmlChar *xmlNamespaceURI;
@property (nonatomic, assign) const xmlChar **htmlAttributes;

- (void)appendCharacters:(const char *)charactersFound
                  length:(NSInteger)length;

@end

@interface MXHTMLParser ()

@property (nonatomic, assign) htmlParserCtxtPtr context;
@property (nonatomic) MXMatchList * handlerList;
- (void) raiseError:(NSError *) error;

@end

@implementation MXHTMLParser


- (instancetype) initWithMatches:(NSArray<MXMatch *> *) matches {
    self = [super init];
    if (self) {
        self.context = htmlCreatePushParserCtxt(&simpleHTMLSAXHandlerStruct, (__bridge void *)(self), NULL, 0, NULL, XML_CHAR_ENCODING_UTF8);
        self.handlerList = [[MXMatchList alloc] init];
        self.handlerList.handlers = matches;
    }
    return self;
}
- (instancetype) init
{
    return [self initWithMatches:@[]];
}



- (void) dealloc
{
    if (self.context != NULL) {
        htmlFreeParserCtxt(self.context);
    }
    self.context = NULL;
}

//- (void) addParser:(MXParser *) parser
//{
//    [(NSMutableArray *)self.myParsers addObject:parser];
//}

- (void) parseDataChunk:(NSData *) data
{
//    xmlParseChunk(self.context, (const char *)[data bytes], (int)[data length], 0);
    htmlParseChunk(self.context,  (const char *)[data bytes], (int)[data length], 0);

}


- (void) dataFinished
{
    htmlParseChunk(self.context,NULL, 0, 1);
    
}

- (void) raiseError:(NSError *) error
{
    [self.handlerList errorRaised:error onElement:self.handlerList.elm];
}

@end

#pragma mark SAX Helper Function



#pragma mark SAX Callback Implementations


static void	charactersFoundSAX(void *ctx,
                               const xmlChar *ch,
                               int len)
{
    MXHTMLParser *ctxSelf = (__bridge MXHTMLParser *)ctx;

    MXElement * elm = ctxSelf.handlerList.elm;
    [elm appendCharacters:(const char *)ch length:len];
    
    MXTextElement * telm = [[MXTextElement alloc] initWithContext:ctxSelf];
    [telm appendCharacters:(const char *)ch length:len];
    ctxSelf.handlerList = [ctxSelf.handlerList enterElement:telm];
    ctxSelf.handlerList = [ctxSelf.handlerList exitElement];
    
}


static void errorEncounteredSAX(void *ctx,
                                const char *msg,
                                ...)
{
    va_list args;
    char * fullMessage = NULL;
    if (msg)
    {
        va_start(args, msg);
        vasprintf(&fullMessage, msg, args);
        va_end(args);
    }
    
    MXHTMLParser *ctxSelf = (__bridge MXHTMLParser *)ctx;
    NSString * str = fullMessage ? [NSString stringWithUTF8String:(const char *)fullMessage] : @"";
    NSError * error = [NSError errorWithDomain:@"com.mirrorxml.libxml2" code:1 userInfo:@{NSLocalizedDescriptionKey:str}];
    
    [ctxSelf raiseError:error];

}

static void startDocumentSAX (void *ctx)
{
    MXHTMLParser *ctxSelf = (__bridge MXHTMLParser *)ctx;
    [ctxSelf.handlerList streamReset];
}

static void startElementSAX (void *ctx,
const xmlChar *name,
const xmlChar **atts)
{
    MXHTMLParser *ctxSelf = (__bridge MXHTMLParser *)ctx;

    MXElement * elm = [[MXElement alloc] initWithContext:ctxSelf];

    elm.xmlLocalname = name;
    elm.htmlAttributes = atts;
    
    ctxSelf.handlerList = [ctxSelf.handlerList enterElement:elm];
    
    
    
}
void endElementSAX(void *ctx,
                           const xmlChar *name)
{
    MXHTMLParser *ctxSelf = (__bridge MXHTMLParser *)ctx;
    ctxSelf.handlerList = [ctxSelf.handlerList exitElement];
}

static xmlSAXHandler simpleHTMLSAXHandlerStruct = {
    NULL,                       /* internalSubset */
    NULL,                       /* isStandalone   */
    NULL,                       /* hasInternalSubset */
    NULL,                       /* hasExternalSubset */
    NULL,                       /* resolveEntity */
    NULL,                       /* getEntity */
    NULL,                       /* entityDecl */
    NULL,                       /* notationDecl */
    NULL,                       /* attributeDecl */
    NULL,                       /* elementDecl */
    NULL,                       /* unparsedEntityDecl */
    NULL,                       /* setDocumentLocator */
    startDocumentSAX,              /* startDocument */
    NULL,                       /* endDocument */
    startElementSAX,                       /* startElement*/
    endElementSAX,                       /* endElement */
    NULL,                       /* reference */
    charactersFoundSAX,         /* characters */
    NULL,                       /* ignorableWhitespace */
    NULL,                       /* processingInstruction */
    NULL,                       /* comment */
    NULL,                       /* warning */
    errorEncounteredSAX,        /* error */
    NULL,                       /* fatalError //: unused error() get all the errors */
    NULL,                       /* getParameterEntity */
    charactersFoundSAX,         /* cdataBlock */
    NULL,                       /* externalSubset */
    XML_SAX2_MAGIC,             //
    NULL,
    NULL,            /* startElementNs */
    NULL,              /* endElementNs */
    NULL,                       /* serror */
};
