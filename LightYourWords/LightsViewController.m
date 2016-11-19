//
//  LightsViewController.m
//  LightYourWords
//
//  Created by Yevhen Kim on 2016-11-16.
//  Copyright © 2016 Yevhen Kim. All rights reserved.
//

#import "LightsViewController.h"
#import "AppDelegate.h"
#import <HueSDK_iOS/HueSDK.h>

#define MAX_HUE 65535

@interface LightsViewController ()
@property (weak, nonatomic) IBOutlet UITextView *wordsRecognizerTextField;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;

@property (nonatomic, assign) BOOL usingStartingLanguageModel;
@property (nonatomic, assign) int restartAttemptsDueToPermissionRequests;
@property (nonatomic, assign) BOOL startupFailedDueToLackOfPermissions;


// Things which help us show off the dynamic language features.
@property (nonatomic, copy) NSString *pathToFirstDynamicallyGeneratedLanguageModel;
@property (nonatomic, copy) NSString *pathToFirstDynamicallyGeneratedDictionary;
@property (nonatomic, copy) NSString *pathToSecondDynamicallyGeneratedLanguageModel;
@property (nonatomic, copy) NSString *pathToSecondDynamicallyGeneratedDictionary;

@end

@implementation LightsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.fliteController = [[OEFliteController alloc] init];
    self.slt = [[Slt alloc] init];
    self.openEarsEventsObserver = [[OEEventsObserver alloc] init];
    self.openEarsEventsObserver.delegate = self;
    
    
    self.restartAttemptsDueToPermissionRequests = 0;
    self.startupFailedDueToLackOfPermissions = FALSE;
    
    [OELogging startOpenEarsLogging];
    [OEPocketsphinxController sharedInstance].verbosePocketSphinx = TRUE;
    [self.openEarsEventsObserver setDelegate:self];
    [[OEPocketsphinxController sharedInstance] setActive:TRUE error:nil];
    [self prepareDynamicLanguageGenerator];
    
    self.startButton.hidden = TRUE;
}

#pragma mark - setting up dynamic language generator

- (void)prepareDynamicLanguageGenerator {
    OELanguageModelGenerator *languageModelGenerator = [[OELanguageModelGenerator alloc]init];
    
    NSArray *lamps = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"random"];
    NSError *error = [languageModelGenerator generateLanguageModelFromArray:lamps withFilesNamed:@"FirstOpenEarsDynamicLanguageModel" forAcousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"]];
    
    if(error) {
        NSLog(@"Dynamic language generator reported error %@", [error description]);
    } else {
        self.pathToFirstDynamicallyGeneratedLanguageModel = [languageModelGenerator pathToSuccessfullyGeneratedLanguageModelWithRequestedName:@"FirstOpenEarsDynamicLanguageModel"];
        self.pathToFirstDynamicallyGeneratedDictionary = [languageModelGenerator pathToSuccessfullyGeneratedDictionaryWithRequestedName:@"FirstOpenEarsDynamicLanguageModel"];
    }
    
    self.usingStartingLanguageModel = TRUE; // This is not an OpenEars thing, this is just so I can switch back and forth between the two models in this sample app.
    
    NSArray *commands = @[@"random"];
    error = [languageModelGenerator generateLanguageModelFromArray:commands withFilesNamed:@"SecondOpenEarsDynamicLanguageModel" forAcousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"]];
    
    if(error) {
        NSLog(@"Dynamic language generator reported error %@", [error description]);
    }	else {
        
        self.pathToSecondDynamicallyGeneratedLanguageModel = [languageModelGenerator pathToSuccessfullyGeneratedLanguageModelWithRequestedName:@"SecondOpenEarsDynamicLanguageModel"]; // We'll set our new .languagemodel file to be the one to get switched to when the words "CHANGE MODEL" are recognized.
        self.pathToSecondDynamicallyGeneratedDictionary = [languageModelGenerator pathToSuccessfullyGeneratedDictionaryWithRequestedName:@"SecondOpenEarsDynamicLanguageModel"];; // We'll set our new dictionary to be the one to get switched to when the words "CHANGE MODEL" are recognized.
        
        // Next, an informative message.
        
        NSLog(@"\n\nWelcome to the OpenEars sample project. This project understands the words:\n%@,\nand if you say \"change model\" (assuming you haven't altered that trigger phrase in this sample app) it will switch to its dynamically-generated model which understands the words:\n%@", lamps, commands);
        
        // This is how to start the continuous listening loop of an available instance of OEPocketsphinxController. We won't do this if the language generation failed since it will be listening for a command to change over to the generated language.
        
        [[OEPocketsphinxController sharedInstance] setActive:TRUE error:nil]; // Call this once before setting properties of the OEPocketsphinxController instance.
        
        //   [OEPocketsphinxController sharedInstance].pathToTestFile = [[NSBundle mainBundle] pathForResource:@"change_model_short" ofType:@"wav"];  // This is how you could use a test WAV (mono/16-bit/16k) rather than live recognition. Don't forget to add your WAV to your app bundle.
        
        if(![OEPocketsphinxController sharedInstance].isListening) {
            [[OEPocketsphinxController sharedInstance] startListeningWithLanguageModelAtPath:self.pathToFirstDynamicallyGeneratedLanguageModel dictionaryAtPath:self.pathToFirstDynamicallyGeneratedDictionary acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:FALSE]; // Start speech recognition if we aren't already listening.
        }
        // [self startDisplayingLevels] is not an OpenEars method, just a very simple approach for level reading
        // that I've included with this sample app. My example implementation does make use of two OpenEars
        // methods:	the pocketsphinxInputLevel method of OEPocketsphinxController and the fliteOutputLevel
        // method of fliteController.
        //
        // The example is meant to show one way that you can read those levels continuously without locking the UI,
        // by using an NSTimer, but the OpenEars level-reading methods
        // themselves do not include multithreading code since I believe that you will want to design your own
        // code approaches for level display that are tightly-integrated with your interaction design and the
        // graphics API you choose.
        
    }
}

#pragma mark - start stop speech recognizer action

- (IBAction)startSpeechRecognizerButtonPressed:(UIButton *)sender {
    
    [self.fliteController say:@"Choose your lamp" withVoice:self.slt];
    
    if(![OEPocketsphinxController sharedInstance].isListening) {
        [[OEPocketsphinxController sharedInstance] startListeningWithLanguageModelAtPath:self.pathToFirstDynamicallyGeneratedLanguageModel dictionaryAtPath:self.pathToFirstDynamicallyGeneratedDictionary acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:FALSE]; // Start speech recognition if we aren't already listening.
    }
    self.startButton.hidden = TRUE;
}

- (IBAction)stopSpeechRecognizerButtonPressed:(UIButton *)sender {
    NSError *error = nil;
    if([OEPocketsphinxController sharedInstance].isListening) { // Stop if we are currently listening.
        error = [[OEPocketsphinxController sharedInstance] stopListening];
        if(error)NSLog(@"Error stopping listening in stopButtonAction: %@", error);
    }
    self.startButton.hidden = FALSE;
}



#pragma mark - OEEventsObserver delegate methods

- (void)pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID {
    NSLog(@"the received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID);
    
    if([hypothesis isEqualToString:@"change model"]) { // If the user says "change model", we will switch to the alternate model (which happens to be the dynamically generated model).
        
        // Here is an example of language model switching in OpenEars. Deciding on what logical basis to switch models is your responsibility.
        // For instance, when you call a customer service line and get a response tree that takes you through different options depending on what you say to it,
        // the models are being switched as you progress through it so that only relevant choices can be understood. The construction of that logical branching and
        // how to react to it is your job; OpenEars just lets you send the signal to switch the language model when you've decided it's the right time to do so.
        
        if(self.usingStartingLanguageModel) { // If we're on the starting model, switch to the dynamically generated one.
            
            [[OEPocketsphinxController sharedInstance] changeLanguageModelToFile:self.pathToSecondDynamicallyGeneratedLanguageModel withDictionary:self.pathToSecondDynamicallyGeneratedDictionary];
            self.usingStartingLanguageModel = FALSE;
            
        } else { // If we're on the dynamically generated model, switch to the start model (this is an example of a trigger and method for switching models).
            
            [[OEPocketsphinxController sharedInstance] changeLanguageModelToFile:self.pathToFirstDynamicallyGeneratedLanguageModel withDictionary:self.pathToFirstDynamicallyGeneratedDictionary];
            self.usingStartingLanguageModel = TRUE;
        }
    }
    
    self.wordsRecognizerTextField.text = [NSString stringWithFormat:@"Heard: \"%@\"", hypothesis]; // Show it in the status box.
    
    // This is how to use an available instance of OEFliteController. We're going to repeat back the command that we heard with the voice we've chosen.
    [self.fliteController say:[NSString stringWithFormat:@"You said %@",hypothesis] withVoice:self.slt];

    
}

- (void)pocketsphinxDidStartListening {
    NSLog(@" Pocketsphinix is now listening");
    self.startButton.hidden = TRUE; // React to it with some UI changes.
    self.stopButton.hidden = FALSE;
}

- (void)pocketsphinxDidDetectSpeech {
    NSLog(@"Pocketsphinix has detected speech");
}

- (void)pocketsphinxDidDetectFinishedSpeech {
    NSLog(@"Pocketsphinix has detected a period of silence, concluding an utterance");
}

- (void)pocketsphinxDidStopListening {
    NSLog(@"Pocketsphinix has stop listening");
}

- (void)pocketsphinxDidSuspendRecognition {
    NSLog(@"Pocketsphinix has suspended recognition");
}

- (void)pocketsphinxDidResumeRecognition {
    NSLog(@"Pocketsphinix has resumed recognition");
}

- (void)pocketsphinxDidChangeLanguageModelToFile:(NSString *)newLanguageModelPathAsString andDictionary:(NSString *)newDictionaryPathAsString {
    NSLog(@"Pocketsphinix is now using the following language model: \n%@ and the following dictionary: %@", newDictionaryPathAsString, newDictionaryPathAsString);
}

- (void)pocketSphinxContinuousSetupDidFailWithReason:(NSString *)reasonForFailure {
    NSLog(@"Listening setup wasn't successful and returned the failure reason: %@", reasonForFailure);
}

- (void)pocketSphinxContinuousTeardownDidFailWithReason:(NSString *)reasonForFailure {
    NSLog(@"Listening teardown wasn't successful and returned the failure reason: %@", reasonForFailure);
}


#pragma mark - Optional OEEventsObserver methods


// An optional delegate method of OEEventsObserver which informs that the interruption to the audio session ended.

- (void)audioSessionInterruptionDidEnd {
    // We're restarting the previously-stopped listening loop.
    if(![OEPocketsphinxController sharedInstance].isListening){
        [[OEPocketsphinxController sharedInstance] startListeningWithLanguageModelAtPath:self.pathToFirstDynamicallyGeneratedLanguageModel dictionaryAtPath:self.pathToFirstDynamicallyGeneratedDictionary acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:FALSE]; // Start speech recognition if we aren't currently listening.
    }
}

// An optional delegate method of OEEventsObserver which informs that the audio input became unavailable.

- (void) audioInputDidBecomeUnavailable {
    NSLog(@"Local callback:  The audio input has become unavailable"); // Log it.
    NSError *error = nil;
    if([OEPocketsphinxController sharedInstance].isListening){
        error = [[OEPocketsphinxController sharedInstance] stopListening]; // React to it by telling Pocketsphinx to stop listening since there is no available input (but only if we are listening).
        if(error) NSLog(@"Error while stopping listening in audioInputDidBecomeUnavailable: %@", error);
    }
}

// An optional delegate method of OEEventsObserver which informs that the unavailable audio input became available again.

- (void) audioInputDidBecomeAvailable {
    NSLog(@"Local callback: The audio input is available"); // Log it.
    if(![OEPocketsphinxController sharedInstance].isListening) {
        [[OEPocketsphinxController sharedInstance] startListeningWithLanguageModelAtPath:self.pathToFirstDynamicallyGeneratedLanguageModel dictionaryAtPath:self.pathToFirstDynamicallyGeneratedDictionary acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:FALSE]; // Start speech recognition, but only if we aren't already listening.
    }
}

- (void) audioRouteDidChangeToRoute:(NSString *)newRoute {
    NSLog(@"Local callback: Audio route change. The new audio route is %@", newRoute); // Log it.
    NSError *error = [[OEPocketsphinxController sharedInstance] stopListening]; // React to it by telling the Pocketsphinx loop to shut down and then start listening again on the new route
    
    if(error)NSLog(@"Local callback: error while stopping listening in audioRouteDidChangeToRoute: %@",error);
    
    if(![OEPocketsphinxController sharedInstance].isListening) {
        [[OEPocketsphinxController sharedInstance] startListeningWithLanguageModelAtPath:self.pathToFirstDynamicallyGeneratedLanguageModel dictionaryAtPath:self.pathToFirstDynamicallyGeneratedDictionary acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:FALSE]; // Start speech recognition if we aren't already listening.
    }
}

/** Pocketsphinx couldn't start because it has no mic permissions (will only be returned on iOS7 or later).*/

- (void) pocketsphinxFailedNoMicPermissions {
    NSLog(@"Local callback: The user has never set mic permissions or denied permission to this app's mic, so listening will not start.");
    self.startupFailedDueToLackOfPermissions = TRUE;
    if([OEPocketsphinxController sharedInstance].isListening){
        NSError *error = [[OEPocketsphinxController sharedInstance] stopListening]; // Stop listening if we are listening.
        if(error) NSLog(@"Error while stopping listening in micPermissionCheckCompleted: %@", error);
    }
}

/** The user prompt to get mic permissions, or a check of the mic permissions, has completed with a TRUE or a FALSE result  (will only be returned on iOS7 or later).*/

- (void) micPermissionCheckCompleted:(BOOL)result {
    if(result) {
        self.restartAttemptsDueToPermissionRequests++;
        if(self.restartAttemptsDueToPermissionRequests == 1 && self.startupFailedDueToLackOfPermissions) { // If we get here because there was an attempt to start which failed due to lack of permissions, and now permissions have been requested and they returned true, we restart exactly once with the new permissions.
            
            if(![OEPocketsphinxController sharedInstance].isListening) { // If there was no error and we aren't listening, start listening.
                [[OEPocketsphinxController sharedInstance]
                 startListeningWithLanguageModelAtPath:self.pathToFirstDynamicallyGeneratedLanguageModel
                 dictionaryAtPath:self.pathToFirstDynamicallyGeneratedDictionary
                 acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"]
                 languageModelIsJSGF:FALSE]; // Start speech recognition.
                
                self.startupFailedDueToLackOfPermissions = FALSE;
            }
        }
    }
}

- (void) testRecognitionCompleted {
    NSLog(@"A test file that wasn't submitted for recognition is now complete");
    NSError *error = nil;
    if([OEPocketsphinxController sharedInstance].isListening) { // If we're listening, stop listening.
        error = [[OEPocketsphinxController sharedInstance] stopListening];
        if(error) NSLog(@"Error while stopping listening in testRecognitionCompleted: %@", error);
    }
}


@end
