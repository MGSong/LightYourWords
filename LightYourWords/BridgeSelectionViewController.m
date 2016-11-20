//
//  BridgeSelectionViewController.m
//  LightYourWords
//
//  Created by Yevhen Kim on 2016-11-18.
//  Copyright © 2016 Yevhen Kim. All rights reserved.
//

#import "BridgeSelectionViewController.h"
#import "AppDelegate.h"

@interface BridgeSelectionViewController ()

@end

@implementation BridgeSelectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil bridges:(NSDictionary *)bridges delegate:(id<BridgeSelectionViewControllerDelegate>)delegate {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.delegate = delegate;
        self.bridgesList = bridges;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //set title of screen
    self.title = @"Available Smart Bridges";
    
    //refresh button
    UIBarButtonItem *refreshBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                 target:self
                                                 action:@selector(refreshButtonClicked:)];
    self.navigationItem.rightBarButtonItem = refreshBarButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (IBAction)refreshButtonClicked:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [UIAppDelegate searchForBridgeLocal];
}

#pragma mark - TableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.bridgesList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Sort bridges by bridge id
    NSArray *sortedKeys = [self.bridgesList.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    // Get mac address and ip address of selected bridge
    NSString *bridgeId = [sortedKeys objectAtIndex:indexPath.row];
    NSString *ip = [self.bridgesList objectForKey:bridgeId];
    
    // Update cell
    cell.textLabel.text = bridgeId;
    cell.detailTextLabel.text = ip;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @"Please select a SmartBridge to use for this application";
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Sort bridges by bridge id
    NSArray *sortedKeys = [self.bridgesList.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    /***************************************************
     The choice of bridge to use is made, store the bridge id
     and ip address for this bridge
     *****************************************************/
    
    // Get bridge id and ip address of selected bridge
    NSString *bridgeId = [sortedKeys objectAtIndex:indexPath.row];
    NSString *ip = [self.bridgesList objectForKey:bridgeId];
    
    // Inform delegate
    [self.delegate bridgeSelectedWithIpAddress:ip andBridgeId:bridgeId];
}

@end
