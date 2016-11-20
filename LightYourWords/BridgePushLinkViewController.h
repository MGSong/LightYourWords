//
//  BridgePushLinkViewController.h
//  LightYourWords
//
//  Created by Yevhen Kim on 2016-11-18.
//  Copyright © 2016 Yevhen Kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHError;
@class PHHueSDK;

//Delegate protocol
@protocol BridgePushLinkViewControllerDelegate <NSObject>

@required
- (void)pushLinkSuccess;
//Method which is invoked when the pushlinking failed
//@param error The error which caused the pushlinking to fail
- (void)pushLinkFailed:(PHError *)error;

@end

@interface BridgePushLinkViewController : UIViewController

@property (nonatomic, unsafe_unretained) id<BridgePushLinkViewControllerDelegate>delegate;
@property (nonatomic, strong) IBOutlet UIProgressView *progressView;
@property (nonatomic, strong) PHHueSDK *phHueSDK;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil hueSDK:(PHHueSDK *)hueSdk delegate:(id<BridgePushLinkViewControllerDelegate>)delegate;
- (void)startPushLinking;

@end
