//
//  ViewController.h
//  tumbleweed
//
//  Created by David Cascino on 1/22/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Scene.h"
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>



@interface TumbleweedViewController : UIViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate, CLLocationManagerDelegate, AVAudioPlayerDelegate>
{
    NSMutableArray *parallaxLayers;
    UIView *mapCAView;
    IBOutlet UIScrollView *scrollView;
    
    //-- buttons
    IBOutlet UIButton *buttonContainer;
    NSMutableArray *scenes;
    IBOutlet UIButton *foursquareConnectButton;
    
    //audio
    BOOL _backgroundMusicPlaying;
	BOOL _backgroundMusicInterrupted;
	UInt32 _otherMusicIsPlaying;
 
}


//-- buttons
@property (nonatomic, retain) UIButton *foursquareConnectButton;
@property (nonatomic) SystemSoundID systemSound;
@property (nonatomic, retain) AVAudioPlayer *_backgroundMusicPlayer;

//-- shared instance
+ (TumbleweedViewController *) sharedClient;

//-- instance methods
- (void) gameState;
- (void) saveAvatarPosition;
- (void) addProgressBar;

//-- event handlers
- (IBAction) foursquareConnect:(UIButton *)sender;
- (void) handleSingleTap:(UIGestureRecognizer *)sender;
- (void) handleDoubleTap:(UIGestureRecognizer *)sender;


//audio
- (void) loadBGAudio;
- (void) tryPlayMusic: (BOOL) off;
- (void) playSystemSound: (NSString*) name;


@end
