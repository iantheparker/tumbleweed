//
//  CheckInController.h
//  tumbleweed
//
//  Created by Ian Parker on 2/3/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SceneController.h"


@interface CheckInController : UIViewController <UITextViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate>{
    IBOutlet UIButton *backButton;
    IBOutlet UIButton *photoButton;
    IBOutlet UILabel *characterCounter;
    IBOutlet UITextView *shoutTextView;
    NSDictionary *venueDetails;
    IBOutlet UILabel *venueNameLabel;
    NSString *shoutText;
    SceneController *sceneControllerId;
    IBOutlet UIActivityIndicatorView *activityIndicator;
    IBOutlet UIButton *facebookButton;
    IBOutlet UIButton *twitterButton;
}

@property (nonatomic, retain) NSDictionary *venueDetails;
@property (nonatomic, retain) UILabel *venueNameLabel;
@property (nonatomic, retain) NSString *shoutText;
@property (nonatomic, retain) UILabel *characterCounter;
@property (nonatomic, retain) UITextView *shoutTextView;
@property (nonatomic, strong) SceneController *sceneControllerId;
@property (nonatomic, retain) UIButton *photoButton;
@property (nonatomic, retain) UIButton *facebookButton;
@property (nonatomic, retain) UIButton *twitterButton;

- (IBAction)checkIn:(id)sender;
- (IBAction)toggleFacebookShare:(id)sender;
- (IBAction)toggleTwitterShare:(id)sender;
- (IBAction)photoActionTapped:(id)sender;
- (IBAction)dismissModal:(id)sender;
- (id) initWithSenderId: (SceneController *)sender;
-(void)takePhoto: (NSInteger)sourceType;

- (void) shareAlertButton;


@end
