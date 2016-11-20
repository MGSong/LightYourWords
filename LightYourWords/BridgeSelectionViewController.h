//
//  BridgeSelectionViewController.h
//  LightYourWords
//
//  Created by Yevhen Kim on 2016-11-18.
//  Copyright © 2016 Yevhen Kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BridgeSelectionViewControllerDelegate <NSObject>

//Informs the delegate which bridge was selected
//@param ipAddress of selected bridge
//@param macAddress the mac address of the selected bridge
- (void)bridgeSelectedWithIpAddress:(NSString *)ipAddress andBridgeId:(NSString *)bridgeId;

@end

@interface BridgeSelectionViewController : UIViewController

//the delegate object
@property (nonatomic, unsafe_unretained) id<BridgeSelectionViewControllerDelegate>delegate;
@property (nonatomic, strong) NSDictionary *bridgesList;

// @param bridges the bridges to show in the list
//@param delegate the delegate to inform when a bridge is selected

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil bridges:(NSDictionary *)bridges delegate:(id<BridgeSelectionViewControllerDelegate>)delegate;

@end
