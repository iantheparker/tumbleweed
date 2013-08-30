//
//  SceneController.h
//  tumbleweed
//
//  Created by David Cascino on 1/25/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "FoursquareAnnotation.h"
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>
#import <AVFoundation/AVFoundation.h>
#import "Scene.h"
@class Scene;


@interface SceneController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate>
{
    IBOutlet UIScrollView *sceneScrollView;
    IBOutlet UIView *sceneSVView;
    IBOutlet UILabel *sceneTitle;
    IBOutlet UILabel *unlockCopy;
    IBOutlet UIScrollView *venueScrollView;
    IBOutlet UIView *venueDetailNib;
    IBOutlet UIActivityIndicatorView *activityIndicator;
    IBOutlet UIButton *refreshButton;
    IBOutlet UIButton *leftScroll;
    IBOutlet UIButton *rightScroll;
    IBOutlet MKMapView *mvFoursquare;
    IBOutlet UIView *searchView;
    IBOutlet UIButton *movieThumbnailButton;
    IBOutlet UIView *extrasView;
    IBOutlet UIView *introView;
    IBOutlet UIView *contentView;
    IBOutlet UIView *movieView;
    IBOutlet UIButton *checkinButton;
    IBOutlet UILabel *checkinInstructions;
    IBOutlet UIImageView *sceneTitleIV;
    IBOutlet UIButton *playButton;


    CLLocationManager *locationManager;
    //MPMoviePlayerController *moviePlayer;
    UIView *venueView;
    
}

@property (nonatomic, retain) UIScrollView *sceneScrollView;
@property (nonatomic, retain) UIScrollView *venueScrollView;
@property (nonatomic, retain) UILabel *sceneTitle;
@property (nonatomic, retain) UILabel *unlockCopy;
@property (nonatomic, retain) UIView *sceneSVView;
@property (nonatomic, retain) UIView *venueDetailNib;
@property (nonatomic, retain) UIView *venueView;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, retain) MPMoviePlayerViewController *moviePlayer;
@property (nonatomic, retain) MKMapView *mvFoursquare;
@property (nonatomic, getter = isPinsLoaded) BOOL pinsLoaded;
@property (nonatomic, retain) UIButton *refreshButton;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) UIButton *leftScroll;
@property (nonatomic, retain) UIButton *rightScroll;
@property (nonatomic, retain) UIButton *movieThumbnailButton;
@property (nonatomic, retain) UIView *movieView;
@property (nonatomic, retain) UIView *extrasView;
@property (nonatomic, readonly) Scene *scene;

@property (nonatomic, retain) NSString *successfulVenueName;
@property (nonatomic, retain) UIButton *checkinButton;
@property (nonatomic, retain) UILabel *checkinInstructions;
@property (nonatomic, retain) UIImageView *sceneTitleIV;
@property (nonatomic, retain) UIButton *playButton;


//initializers
- (id) initWithScene: (Scene *) scn;

// touch events
- (IBAction) dismissModal:(id)sender;
- (IBAction) playVideo:(id)sender ;
- (IBAction)refreshSearch:(id)sender;
- (IBAction)leftScroll :(id)sender;
- (IBAction)rightScroll :(id)sender;

- (void) animateRewards : (NSTimeInterval) duration :(BOOL) withVideo;
- (void) videoPlayBackDidFinish:(NSNotification *) notification;
- (void) movieFinishedCallback:(NSNotification*) aNotification;
- (void) movieExitFullscreen:(NSNotification*) aNotification;

//
- (void) handleSingleTap:(UIGestureRecognizer *)sender;






@end
