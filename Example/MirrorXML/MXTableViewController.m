//
//  MXTableViewController.m
//  MirrorXML_Example
//
//  Created by Mike Spears on 2019-01-14.
//  Copyright © 2019 samesimilar@gmail.com. All rights reserved.
//

#import "MXTableViewController.h"
#import "MirrorXML_Example-Swift.h"

@interface MXTableViewController ()
@property NSArray * items;
@end

@implementation MXTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    self.items = [[[ReadOPML alloc] init] readOPML];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"basic" forIndexPath:indexPath];
    
    OPMLItem * item = self.items[indexPath.row];
    cell.textLabel.text = item.title;

    return cell;
}

@end
