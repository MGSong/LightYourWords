//
//  AppDelegate.h
//  LightYourWords
//
//  Created by Yevhen Kim on 2016-11-16.
//  Copyright © 2016 Yevhen Kim. All rights reserved.
//
#define UIAppDelegate  ((AppDelegate *)[[UIApplication sharedApplication] delegate])

#import <UIKit/UIKit.h>
#import <HueSDK_iOS/HueSDK.h>
#import "BridgePushLinkViewController.h"
#import "BridgeSelectionViewController.h"

@class LightsViewController;
@class PHHueSDK;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate, BridgePushLinkViewControllerDelegate, BridgeSelectionViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) PHHueSDK *phHueSDK;

#pragma mark - HueSDK

//Starts the local heartbeat
- (void)enableLocalHeartbeat;

//Stops the local heartbeat
- (void)disableLocalHeartbeat;

//Starts a search for a bridge
- (void)searchForBridgeLocal;

@end

