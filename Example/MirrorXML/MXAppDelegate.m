//
//  MXAppDelegate.m
//  MirrorXML
//
//  Created by samesimilar@gmail.com on 02/13/2018.
//  Copyright (c) 2018 samesimilar@gmail.com. All rights reserved.
//

#import "MXAppDelegate.h"
#import <MirrorXML/MirrorXML.h>
#import <MirrorXML/MXHTML.h>
#import "MirrorXML_Example-Swift.h"

@implementation MXAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
//    MXMatch *ownerName = [[MXMatch alloc] initWithPath:@"/opml/head/ownerName"];
//    ownerName.exitHandler = ^(MXElement * _Nonnull elm) {
//        NSLog(@"%@", elm.text);
//    };
//
//    MXMatch *body = [[MXMatch alloc] initWithPath:@"//body"];
//    body.entryHandler = ^NSArray<MXMatch *> * _Nonnull(MXElement * _Nonnull elm) {
//
//        MXMatch * outline = [[MXMatch alloc] initWithPath:@"/outline"];
//        outline.exitHandler = ^(MXElement * _Nonnull elm) {
//            NSLog(@"%@", elm.attributes[@"description"]);
//        };
//
//        return @[outline];
//    };
//
//    MXParser *parser = [[MXParser alloc] initWithMatches:@[ownerName, body]];
//
//    NSData *data = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"subscriptionList" withExtension:@"opml"]];
//
//    [parser parseDataChunk:data];
//    [parser dataFinished];
    
    SwiftTest *test = [[SwiftTest alloc] init];
//    [test readWiki];
    [test test];
    [test plistParser];
    
    MXHTMLToAttributedString * htmlparser = [[MXHTMLToAttributedString alloc] init];
    htmlparser.detectParsingErrors = NO;
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
