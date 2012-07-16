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
#import "Tumbleweed.h"
#import <QuartzCore/QuartzCore.h>



@interface TumbleweedViewController : UIViewController <UIScrollViewDelegate, CLLocationManagerDelegate>
{
    Tumbleweed *weed;
    CALayer *map0CA;
    CALayer *map1CA;
    CALayer *map2CA;
    CALayer *map4CA;
    CALayer *janeAvatar;
    UIView *mapCAView;
    IBOutlet UIScrollView *scrollView;
    int lastContentOffset;
    BOOL walkingForward;
    //-- buttons
    IBOutlet UIView *buttonContainer;
    IBOutlet UIButton *foursquareConnectButton;
    IBOutlet UIButton *introButton;
    IBOutlet UIButton *dealButton;
    IBOutlet UIButton *barButton;
    IBOutlet UIButton *gasStationButton;
    IBOutlet UIButton *riverBed1Button;
    IBOutlet UIButton *riverBed2Button;
    IBOutlet UIButton *desertChaseButton;
    IBOutlet UIButton *desertLynchButton;
    IBOutlet UIButton *campFireButton;    
}


//-- buttons
@property (nonatomic, retain) UIButton *foursquareConnectButton;
@property (nonatomic, retain) UIButton *introButton;
@property (nonatomic, retain) UIButton *dealButton;
@property (nonatomic, retain) UIButton *barButton;
@property (nonatomic, retain) UIButton *gasStationButton;
@property (nonatomic, retain) UIButton *riverBed1Button;
@property (nonatomic, retain) UIButton *riverBed2Button;
@property (nonatomic, retain) UIButton *desertChaseButton;
@property (nonatomic, retain) UIButton *desertLynchButton;
@property (nonatomic, retain) UIButton *campFireButton;

//-- instance methods
- (void) gameState;
- (void) saveAvatarPosition;

//-- event handlers
- (IBAction) foursquareConnect:(UIButton *)sender;
- (IBAction) introPressed:(UIButton *)sender;
- (IBAction) dealPressed:(UIButton *)sender;
- (IBAction) barPressed:(UIButton *)sender;
- (IBAction) gasStationPressed:(UIButton *)sender;
- (IBAction) riverbed1Pressed:(UIButton *)sender;
- (IBAction) riverbed2Pressed:(UIButton *)sender;
- (IBAction) desertChasePressed:(UIButton *)sender;
- (IBAction) desertLynchPressed:(UIButton *)sender;
- (IBAction) campFirePressed:(UIButton *)sender;
- (IBAction) handleSingleTap:(UIGestureRecognizer *)sender;



@end
