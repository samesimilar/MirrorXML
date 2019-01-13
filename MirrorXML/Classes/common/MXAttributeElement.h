//
//  MXAttributeElement.h
//  MirrorXML
//
//  Created by Mike Spears on 2018-02-19.
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

#import <Foundation/Foundation.h>

#import "MXElement.h"

/**
 This subclass of MXElement represents the data of a single attribute. Only the attrName, attrValue, attrNamespace property values are defined.
*/
@interface MXAttributeElement : MXElement
/**
 The case-sensitive attribute name, not including the namespace or prefix.
*/
@property (nonatomic, nonnull, readonly) NSString *attrName;
/**
 The attribute value.
*/
@property (nonatomic, nullable, readonly) NSString *attrValue;
/**
 The case-sensitive namepace URI.
*/
@property (nonatomic, nullable, readonly) NSString *attrNamespace;
@end
