//
//  LightsViewController.h
//  LightYourWords
//
//  Created by Yevhen Kim on 2016-11-16.
//  Copyright © 2016 Yevhen Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Slt/Slt.h>
#import <OpenEars/OEFliteController.h>
#import <OpenEars/OEEventsObserver.h>
#import <OpenEars/OELogging.h>
#import <OpenEars/OELanguageModelGenerator.h>
#import <OpenEars/OEAcousticModel.h>
#import <OpenEars/OEPocketsphinxController.h>

@interface LightsViewController : UIViewController <OEEventsObserverDelegate>

// These three are the important OpenEars objects that this class demonstrates the use of.
@property (strong, nonatomic) OEFliteController *fliteController;
@property (strong, nonatomic) Slt *slt;
@property (strong, nonatomic) OEEventsObserver *openEarsEventsObserver;

@end
