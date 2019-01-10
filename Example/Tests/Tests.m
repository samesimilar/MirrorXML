//
//  MirrorXMLTests.m
//  MirrorXMLTests
//
//  Created by samesimilar@gmail.com on 02/13/2018.
//  Copyright (c) 2018 samesimilar@gmail.com. All rights reserved.
//

@import XCTest;
@import MirrorXML;

@interface Tests : XCTestCase
@property (nonatomic) NSData * testData;

@end

@implementation Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    NSURL * dataurl = [[NSBundle mainBundle] URLForResource:@"tests" withExtension:@"xml"];
    self.testData = [NSData dataWithContentsOfURL:dataurl];
    XCTAssertNotNil(self.testData, @"Could not load test data.");
    
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testStructure1
{
    // must do callbacks for children at a single level
    __block int entryCount = 0;
    __block int exitCount = 0;
    MXMatch * child = [[MXMatch alloc] initWithPath:@"/root/testStructure/child" error:nil];
    child.entryHandler = ^MXInnerMatches(MXElement * _Nonnull elm) {
        entryCount++;
        XCTAssertEqualObjects(elm.elementName, @"child", @"Incorrect element name in %s", __PRETTY_FUNCTION__);
        return nil;
    };
    child.exitHandler = ^(MXElement * _Nonnull elm) {
        XCTAssertEqualObjects(elm.elementName, @"child", @"Incorrect element name in %s", __PRETTY_FUNCTION__);
        exitCount++;
    };
    
    MXParser * parser = [[MXParser alloc] initWithMatches:@[child]];
    [parser parseDataChunk:self.testData];
    [parser dataFinished];
    
    XCTAssertEqual(entryCount, 3, @"Incorrect element count in %s", __PRETTY_FUNCTION__);
    XCTAssertEqual(entryCount, exitCount, @"Entry and exit counts must be equal. %s", __PRETTY_FUNCTION__);
    
}

- (void) testStructure1b {
    // must do callbacks for children at arbitrary levels
    __block int entryCount = 0;
    __block int exitCount = 0;
    
    MXMatch * child = [[MXMatch alloc] initWithPath:@"/root/testStructure//child" error:nil];
    child.entryHandler = ^MXInnerMatches(MXElement * _Nonnull elm) {
        entryCount++;
        return nil;
    };
    child.exitHandler = ^(MXElement * _Nonnull elm) {
        exitCount++;
        XCTAssertNotNil(elm.parent, @"Parent of child must not be nil in %s", __PRETTY_FUNCTION__);
    };
    
    MXParser * parser = [[MXParser alloc] initWithMatches:@[child]];
    [parser parseDataChunk:self.testData];
    [parser dataFinished];
    
    XCTAssertEqual(entryCount, 4, @"Incorrect element count in %s", __PRETTY_FUNCTION__);
    XCTAssertEqual(entryCount, exitCount, @"Entry and exit counts must be equal. %s", __PRETTY_FUNCTION__);
}

- (void) testStructure1c {
    // must handle child blocks
    __block int entryCount = 0;
    MXMatch * child = [[MXMatch alloc] initWithPath:@"/root/testStructure/child" error:nil];
    child.entryHandler = ^MXInnerMatches(MXElement * _Nonnull elm) {
        MXMatch * innerChild = [[MXMatch alloc] initWithPath:@"/child" error:nil];
        innerChild.entryHandler = ^MXInnerMatches(MXElement * _Nonnull elm) {
            XCTAssertNotNil(elm.parent, @"Parent of child must not be nil in %s", __PRETTY_FUNCTION__);
            entryCount++;
            return nil;
        };
        innerChild.exitHandler = ^(MXElement * _Nonnull elm) {
            XCTAssertEqualObjects(elm.text, @"Inner child.", @"Inner child text not correct in %s", __PRETTY_FUNCTION__);
        };
        return @[innerChild];
    };
    MXParser * parser = [[MXParser alloc] initWithMatches:@[child]];
    [parser parseDataChunk:self.testData];
    [parser dataFinished];
    XCTAssertEqual(entryCount, 1, @"Incorrect element count in %s", __PRETTY_FUNCTION__);
}

- (void) testStructure1d {
    // must match for multiple paths from '|' operator in path
    __block int entryCount = 0;
    __block int exitCount = 0;
    MXMatch * child = [[MXMatch alloc] initWithPath:@"/root/testStructure/child|/root/testStructure/otherChild" error:nil];
    child.entryHandler = ^MXInnerMatches(MXElement * _Nonnull elm) {
        entryCount++;
        return nil;
    };
    child.exitHandler = ^(MXElement * _Nonnull elm) {
        exitCount++;
    };
    
    MXParser * parser = [[MXParser alloc] initWithMatches:@[child]];
    [parser parseDataChunk:self.testData];
    [parser dataFinished];
    
    XCTAssertEqual(entryCount, 4, @"Incorrect element count in %s", __PRETTY_FUNCTION__);
    XCTAssertEqual(entryCount, exitCount, @"Entry and exit counts must be equal. %s", __PRETTY_FUNCTION__);
    
}


- (void) testStructure1e {
    // must call root exit callback
    __block int entryCount = 0;
    __block int exitCount = 0;
    
    MXMatch * child = [[MXMatch alloc] initWithPath:@"/root/testStructure//child" error:nil];
    child.entryHandler = ^MXInnerMatches(MXElement * _Nonnull elm) {
        entryCount++;
        MXMatch * rootExit = [MXMatch onRootExit:^(MXElement * _Nonnull elm) {
            exitCount++;
        }];
        return @[rootExit];
    };

    
    MXParser * parser = [[MXParser alloc] initWithMatches:@[child]];
    [parser parseDataChunk:self.testData];
    [parser dataFinished];
    
    XCTAssertEqual(entryCount, 4, @"Incorrect element count in %s", __PRETTY_FUNCTION__);
    XCTAssertEqual(entryCount, exitCount, @"Entry and exit counts must be equal. %s", __PRETTY_FUNCTION__);
    
}

- (void) testStructure1Attribute {
    // must match only 'child' elements with a particular attribute name
    __block int entryCount = 0;
    __block int exitCount = 0;
    __block int attributeHandler = 0;
    MXMatch * child = [[MXMatch alloc] initWithPath:@"/root/testStructure/child/@src" error:nil];
    child.entryHandler = ^MXInnerMatches(MXElement * _Nonnull elm) {
        entryCount++;
        return nil;
    };
    child.exitHandler = ^(MXElement * _Nonnull elm) {
        exitCount++;
    };
    child.attributeHandler = ^(MXAttributeElement * _Nonnull elm) {
        attributeHandler++;
        XCTAssertEqualObjects(elm.attrValue, @"http://example.com/url/2", "Expected value not found in %s", __PRETTY_FUNCTION__);
    };
    
    MXParser * parser = [[MXParser alloc] initWithMatches:@[child]];
    [parser parseDataChunk:self.testData];
    [parser dataFinished];
    
    XCTAssertEqual(entryCount, 0, @"Incorrect element count in %s", __PRETTY_FUNCTION__);
    XCTAssertEqual(entryCount, exitCount, @"Entry and exit counts must be equal. %s", __PRETTY_FUNCTION__);
    XCTAssertEqual(attributeHandler, 1, @"Incorrect attribute handler count in %s", __PRETTY_FUNCTION__);
}

- (void) testStructure1Attribute2 {
    // must match any element with a particular attribute name
    __block int entryCount = 0;
    __block int exitCount = 0;
    __block int attributeHandler = 0;
    MXMatch * child = [[MXMatch alloc] initWithPath:@"/root/testStructure/*/@src" error:nil];
    child.entryHandler = ^MXInnerMatches(MXElement * _Nonnull elm) {
        entryCount++;
        return nil;
    };
    child.exitHandler = ^(MXElement * _Nonnull elm) {
        exitCount++;
    };
    child.attributeHandler = ^(MXAttributeElement * _Nonnull elm) {
        attributeHandler++;

    };
    
    MXParser * parser = [[MXParser alloc] initWithMatches:@[child]];
    [parser parseDataChunk:self.testData];
    [parser dataFinished];
    
    XCTAssertEqual(entryCount, 0, @"Incorrect element count in %s", __PRETTY_FUNCTION__);
    XCTAssertEqual(entryCount, exitCount, @"Entry and exit counts must be equal. %s", __PRETTY_FUNCTION__);
    XCTAssertEqual(attributeHandler, 2, @"Incorrect attribute handler count in %s", __PRETTY_FUNCTION__);
}

- (void) testStructure1Attribute3 {
    // must match elements at any collapsed level with a particular attribute name
    __block int entryCount = 0;
    __block int exitCount = 0;
    __block int attributeHandler = 0;
    MXMatch * child = [[MXMatch alloc] initWithPath:@"/root/testStructure//@src" error:nil];
    child.entryHandler = ^MXInnerMatches(MXElement * _Nonnull elm) {
        entryCount++;
        return nil;
    };
    child.exitHandler = ^(MXElement * _Nonnull elm) {
        exitCount++;
    };
    child.attributeHandler = ^(MXAttributeElement * _Nonnull elm) {
        attributeHandler++;
    };
    
    MXParser * parser = [[MXParser alloc] initWithMatches:@[child]];
    [parser parseDataChunk:self.testData];
    [parser dataFinished];
    
    XCTAssertEqual(entryCount, 0, @"Incorrect element count in %s", __PRETTY_FUNCTION__);
    XCTAssertEqual(entryCount, exitCount, @"Entry and exit counts must be equal. %s", __PRETTY_FUNCTION__);
    XCTAssertEqual(attributeHandler, 3, @"Incorrect attribute handler count in %s", __PRETTY_FUNCTION__);
}

- (void) testStructure1Wildcard1 {
    //must match any element at a particular level
    __block int entryCount = 0;
    __block int exitCount = 0;
    
    MXMatch * child = [[MXMatch alloc] initWithPath:@"/root/testStructure/*" error:nil];
    child.entryHandler = ^MXInnerMatches(MXElement * _Nonnull elm) {
        entryCount++;
        return nil;
    };
    child.exitHandler = ^(MXElement * _Nonnull elm) {
        exitCount++;
    };

    
    MXParser * parser = [[MXParser alloc] initWithMatches:@[child]];
    [parser parseDataChunk:self.testData];
    [parser dataFinished];
    
    XCTAssertEqual(entryCount, 5, @"Incorrect element count in %s", __PRETTY_FUNCTION__);
    XCTAssertEqual(entryCount, exitCount, @"Entry and exit counts must be equal. %s", __PRETTY_FUNCTION__);
   
}

- (void) testStructure1Wildcard2 {
    // must match any element at any level
    __block int entryCount = 0;
    __block int exitCount = 0;
    
    MXMatch * child = [[MXMatch alloc] initWithPath:@"/root/testStructure//*" error:nil];
    child.entryHandler = ^MXInnerMatches(MXElement * _Nonnull elm) {
        entryCount++;
        return nil;
    };
    child.exitHandler = ^(MXElement * _Nonnull elm) {
        exitCount++;
    };
    
    
    MXParser * parser = [[MXParser alloc] initWithMatches:@[child]];
    [parser parseDataChunk:self.testData];
    [parser dataFinished];
    
    XCTAssertEqual(entryCount, 6, @"Incorrect element count in %s", __PRETTY_FUNCTION__);
    XCTAssertEqual(entryCount, exitCount, @"Entry and exit counts must be equal. %s", __PRETTY_FUNCTION__);
    
}

- (void) testStructure1Text1 {
    // must call text handler when it finds text inside matched element
    __block int entryCount = 0;
    __block int exitCount = 0;
    __block int textCount = 0;
    
    MXMatch * child = [[MXMatch alloc] initWithPath:@"/root/testStructure/child/child" error:nil];
    child.entryHandler = ^MXInnerMatches(MXElement * _Nonnull elm) {
        entryCount++;
        return nil;
    };
    child.exitHandler = ^(MXElement * _Nonnull elm) {
        exitCount++;
    };
    child.textHandler = ^(MXElement * _Nonnull elm) {
        textCount++;
        XCTAssertEqualObjects(elm.text, @"Inner child.", "Incorrect text found in %s", __PRETTY_FUNCTION__);
    };
    
    MXParser * parser = [[MXParser alloc] initWithMatches:@[child]];
    [parser parseDataChunk:self.testData];
    [parser dataFinished];
    
    XCTAssertEqual(entryCount, 1, @"Incorrect element count in %s", __PRETTY_FUNCTION__);
    XCTAssertEqual(entryCount, exitCount, @"Entry and exit counts must be equal. %s", __PRETTY_FUNCTION__);
    XCTAssertEqual(textCount, 1, @"Incorrect number of text callbacks in %s", __PRETTY_FUNCTION__);
    
}

- (void) testStructure1Text2 {
    // must call text handler multiple times for text on either 'side' of a child element
    __block int entryCount = 0;
    __block int exitCount = 0;
    __block int textCount = 0;
    __block int brokenTextFound = 0;
    
    MXMatch * child = [[MXMatch alloc] initWithPath:@"/root/testStructure/child" error:nil];
    child.entryHandler = ^MXInnerMatches(MXElement * _Nonnull elm) {
        entryCount++;
        return nil;
    };
    child.exitHandler = ^(MXElement * _Nonnull elm) {
        exitCount++;
    };
    child.textHandler = ^(MXElement * _Nonnull elm) {
        textCount++;
        if (entryCount == 1) {
            brokenTextFound++;
            BOOL correctText = ([elm.text isEqualToString:@"child text."] || [elm.text isEqualToString:@"More child text."]);
            XCTAssertTrue(correctText, @"Incorrect text found in %s", __PRETTY_FUNCTION__);
        }
    };
    
    MXParser * parser = [[MXParser alloc] initWithMatches:@[child]];
    [parser parseDataChunk:self.testData];
    [parser dataFinished];
    
    XCTAssertEqual(entryCount, 3, @"Incorrect element count in %s", __PRETTY_FUNCTION__);
    XCTAssertEqual(entryCount, exitCount, @"Entry and exit counts must be equal. %s", __PRETTY_FUNCTION__);
    XCTAssertEqual(textCount, 4, @"Incorrect number of text callbacks in %s", __PRETTY_FUNCTION__);
    XCTAssertEqual(brokenTextFound, 2, @"Text handler not called multiple times for split text in %s", __PRETTY_FUNCTION__);
    
}

- (void) testNamespace1 {
    // must match namespaced elements separately from ones with default namespace
    __block int entryCount = 0;
    __block int exitCount = 0;
    __block int entryCountNS = 0;
    __block int exitCountNS = 0;
    MXMatch * child = [[MXMatch alloc] initWithPath:@"/root/testNamespaces/child" error:nil];
    child.entryHandler = ^MXInnerMatches(MXElement * _Nonnull elm) {
        entryCount++;
        return nil;
    };
    child.exitHandler = ^(MXElement * _Nonnull elm) {
        exitCount++;
    };
    
    MXMatch * childWithNamespace = [[MXMatch alloc] initWithPath:@"/root/testNamespaces/t:child" namespaces:@{@"t":@"http://example.com/xml/ns1"} error:nil];
    childWithNamespace.entryHandler = ^MXInnerMatches(MXElement * _Nonnull elm) {
        entryCountNS++;
        XCTAssertEqualObjects(elm.namespaceURI, @"http://example.com/xml/ns1", @"Incorrect namespace URI attribute at %s", __PRETTY_FUNCTION__);
        return nil;
    };
    childWithNamespace.exitHandler = ^(MXElement * _Nonnull elm) {
        exitCountNS++;
    };
    
    MXMatch * incorrectNamespace = [[MXMatch alloc] initWithPath:@"/root/testNamespaces/ns:child" namespaces:@{@"ns":@"http://example.com/xml/invalid"} error:nil];
    incorrectNamespace.entryHandler = ^MXInnerMatches(MXElement * _Nonnull elm) {
        entryCountNS++;
        return nil;
    };
    incorrectNamespace.exitHandler = ^(MXElement * _Nonnull elm) {
        exitCountNS++;
    };
    
    
    MXParser * parser = [[MXParser alloc] initWithMatches:@[child, childWithNamespace, incorrectNamespace]];
    [parser parseDataChunk:self.testData];
    [parser dataFinished];
    
    XCTAssertEqual(entryCount, 1, @"Incorrect element count in %s", __PRETTY_FUNCTION__);
    XCTAssertEqual(entryCount, exitCount, @"Entry and exit counts must be equal. %s", __PRETTY_FUNCTION__);
    XCTAssertEqual(entryCountNS, 1, @"Incorrect element count in %s", __PRETTY_FUNCTION__);
    XCTAssertEqual(entryCountNS, exitCountNS, @"Entry and exit counts must be equal. %s", __PRETTY_FUNCTION__);

    
}

- (void) testNamespaceAttribute {
    // must match namespaced attributes separately from attributes with default namespace
    __block int entryCount = 0;
    __block int exitCount = 0;
    __block int attributeHandler = 0;
    MXMatch * child = [[MXMatch alloc] initWithPath:@"/root/testNamespaces/*/@ns:id" namespaces:@{@"ns":@"http://example.com/xml/ns1"} error:nil];
    
    child.entryHandler = ^MXInnerMatches(MXElement * _Nonnull elm) {
        entryCount++;

        return nil;
    };
    child.exitHandler = ^(MXElement * _Nonnull elm) {
        exitCount++;
    };
    child.attributeHandler = ^(MXAttributeElement * _Nonnull elm) {
        attributeHandler++;
        XCTAssertEqualObjects(elm.attrValue, @"c", "Expected value not found in %s", __PRETTY_FUNCTION__);
    };
    
    MXParser * parser = [[MXParser alloc] initWithMatches:@[child]];
    [parser parseDataChunk:self.testData];
    [parser dataFinished];
    
    XCTAssertEqual(entryCount, 0, @"Incorrect element count in %s", __PRETTY_FUNCTION__);
    XCTAssertEqual(entryCount, exitCount, @"Entry and exit counts must be equal. %s", __PRETTY_FUNCTION__);
    XCTAssertEqual(attributeHandler, 1, @"Incorrect attribute handler count in %s", __PRETTY_FUNCTION__);
}

- (void) testNamespaceAttribute2 {
    // namespaced attributes must be organized in dictionary keyed by namespace
    __block int entryCount = 0;
    __block int exitCount = 0;
    
    MXMatch * child = [[MXMatch alloc] initWithPath:@"/root/testNamespaces/otherChild" namespaces:@{} error:nil];
    
    child.entryHandler = ^MXInnerMatches(MXElement * _Nonnull elm) {
        entryCount++;
        XCTAssertEqualObjects(elm.namespacedAttributes[@"http://example.com/xml/ns1"][@"id"], @"c", "Expected value not found in %s", __PRETTY_FUNCTION__);
        XCTAssertNil(elm.attributes[@"id"], @"Attribute with default namespace must be nil in this case %s", __PRETTY_FUNCTION__);
        return nil;
    };
    child.exitHandler = ^(MXElement * _Nonnull elm) {
        exitCount++;
    };

    MXParser * parser = [[MXParser alloc] initWithMatches:@[child]];
    [parser parseDataChunk:self.testData];
    [parser dataFinished];
    
    XCTAssertEqual(entryCount, 1, @"Incorrect element count in %s", __PRETTY_FUNCTION__);
    XCTAssertEqual(entryCount, exitCount, @"Entry and exit counts must be equal. %s", __PRETTY_FUNCTION__);
    
}

- (void) testSpecialText1 {
    // must interpret CDATA properly
    __block int entryCount = 0;
    __block int exitCount = 0;
    
    MXMatch * child = [[MXMatch alloc] initWithPath:@"/root/testSpecial/data1" namespaces:@{} error:nil];
    
    child.entryHandler = ^MXInnerMatches(MXElement * _Nonnull elm) {
        entryCount++;
        return nil;
    };
    child.exitHandler = ^(MXElement * _Nonnull elm) {
        exitCount++;
        XCTAssertEqualObjects(elm.text, @"<<Here is some text.>>", @"Incorrect CDATA text found at %s", __PRETTY_FUNCTION__);
    };
    
    MXParser * parser = [[MXParser alloc] initWithMatches:@[child]];
    [parser parseDataChunk:self.testData];
    [parser dataFinished];
    
    XCTAssertEqual(entryCount, 1, @"Incorrect element count in %s", __PRETTY_FUNCTION__);
    XCTAssertEqual(entryCount, exitCount, @"Entry and exit counts must be equal. %s", __PRETTY_FUNCTION__);
    
}

- (void) testSpecialText2 {
    // must decode entities in text nodes
    __block int entryCount = 0;
    __block int exitCount = 0;
    
    MXMatch * child = [[MXMatch alloc] initWithPath:@"/root/testSpecial/data2" namespaces:@{} error:nil];
    
    child.entryHandler = ^MXInnerMatches(MXElement * _Nonnull elm) {
        entryCount++;
        return nil;
    };
    child.exitHandler = ^(MXElement * _Nonnull elm) {
        exitCount++;
        XCTAssertEqualObjects(elm.text, @"Here are some entities: < > \"", @"Incorrect entity text found at %s", __PRETTY_FUNCTION__);
    };
    
    MXParser * parser = [[MXParser alloc] initWithMatches:@[child]];
    [parser parseDataChunk:self.testData];
    [parser dataFinished];
    
    XCTAssertEqual(entryCount, 1, @"Incorrect element count in %s", __PRETTY_FUNCTION__);
    XCTAssertEqual(entryCount, exitCount, @"Entry and exit counts must be equal. %s", __PRETTY_FUNCTION__);
    
}

- (void) testSpecialText3 {
    // must decode entities in attribute values
    __block int entryCount = 0;
    __block int exitCount = 0;
    
    MXMatch * child = [[MXMatch alloc] initWithPath:@"/root/testSpecial/data3" namespaces:@{} error:nil];
    
    child.entryHandler = ^MXInnerMatches(MXElement * _Nonnull elm) {
        entryCount++;
        XCTAssertEqualObjects(elm.lowercasedAttributes[@"special"], @"Entity inside attribute: \"\"", @"Incorrect entity text found at %s", __PRETTY_FUNCTION__);
        return nil;
    };
    child.exitHandler = ^(MXElement * _Nonnull elm) {
        exitCount++;

    };
    
    MXParser * parser = [[MXParser alloc] initWithMatches:@[child]];
    [parser parseDataChunk:self.testData];
    [parser dataFinished];
    
    XCTAssertEqual(entryCount, 1, @"Incorrect element count in %s", __PRETTY_FUNCTION__);
    XCTAssertEqual(entryCount, exitCount, @"Entry and exit counts must be equal. %s", __PRETTY_FUNCTION__);
    
}

- (void) testError1 {
    // must call the error callback if an error is detected

    __block int errorCount = 0;
    
    MXMatch * child = [[MXMatch alloc] initWithPath:@"/root//*" namespaces:@{} error:nil];
    
 
    child.errorHandler = ^(NSError * _Nonnull error, MXElement * _Nonnull elm) {
        errorCount++;
    };
    
    MXParser * parser = [[MXParser alloc] initWithMatches:@[child]];
    [parser parseDataChunk:self.testData];
    [parser dataFinished];
    
    XCTAssertEqual(errorCount, 1, @"Incorrect error count at %s", __PRETTY_FUNCTION__);
}


@end

