//
//  MXViewController.m
//  MirrorXML
//
//  Created by samesimilar@gmail.com on 02/13/2018.
//  Copyright (c) 2018 samesimilar@gmail.com. All rights reserved.
//

#import "MXViewController.h"
#import "MirrorXML_Example-Swift.h"

@interface MXViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation MXViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    SwiftTest *test = [[SwiftTest alloc] init];
    self.textView.attributedText = [test attributedString];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
