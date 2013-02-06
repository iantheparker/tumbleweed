//
//  CheckInController.m
//  tumbleweed
//
//  Created by Ian Parker on 2/3/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import "CheckInController.h"

@implementation CheckInController

@synthesize venueDetails, venueNameLabel, shoutText, characterCounter, shoutTextView, sceneControllerId, photoButton, facebookButton, twitterButton;


#pragma mark Initializers

- (id) initWithSenderId: (SceneController *) sender
{
    self = [super init];
    // Did the superclass's designated initializer succeed?
    if (self) {
        sceneControllerId = sender;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

#pragma mark Event Handlers


- (IBAction)dismissModal:(id)sender
{
    //NSLog(@"dismissing modal");
    [self dismissModalViewControllerAnimated:YES];
}
- (IBAction)toggleFacebookShare:(id)sender
{
    facebookButton.selected = !facebookButton.selected;
}

- (IBAction)toggleTwitterShare:(id)sender
{
    twitterButton.selected = !twitterButton.selected;
}

- (IBAction)checkIn:(id)sender
{
    [activityIndicator setHidden:NO];
    [activityIndicator startAnimating];
    NSString *broadcastType = [NSString stringWithFormat:@"public,%@,%@", facebookButton.selected ? @"facebook" : @"", twitterButton.selected ? @"twitter" : @""];
    NSLog(@"broadcast type %@", broadcastType);
    
    [Foursquare checkIn:[venueDetails objectForKey:@"id"] shout:shoutText broadcast:broadcastType WithBlock:^(NSDictionary *checkInResponse, NSError *error) {
        if (error) {
            NSLog(@"error checking in %@", error);
        }
        else {
            [self dismissViewControllerAnimated:YES completion:^{
                //sceneControllerId.scene.checkInResponse = checkInResponse;
                //sceneControllerId.scene.unlocked = YES;
                //idempotence - set the gamestate level to the level of this scene
                [Tumbleweed weed].tumbleweedLevel = sceneControllerId.scene.level + 1;
                [sceneControllerId animateRewards];
                NSLog(@"foursquare checkinresponse %@", checkInResponse);

                //NSLog(@"foursquare checkinresponse %@", [[[checkInResponse objectForKey:@"response"] objectForKey:@"checkin"]  objectForKey:@"id"]);
            }];
            
        }
    }];
}


#pragma mark UITextViewDelegate protocol


- (BOOL)textView:(UITextView *)txtView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text 
{    
    if( [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location == NSNotFound ) {
        return YES;
    }
    shoutText = shoutTextView.text;
    NSLog(@"%@", shoutText);

    [txtView resignFirstResponder];
    return NO;
}

- (void)textViewDidChange:(UITextView *)textView
{
    characterCounter.text = [NSString stringWithFormat:@"%d/140", (140 - shoutTextView.text.length)];
    UIColor *redText = [UIColor colorWithRed:212.0/255.0 green:83.0/255.0 blue:88.0/255.0 alpha:1.0];
    UIColor *brownText = [UIColor colorWithRed:62.0/255.0 green:43.0/255.0 blue:26.0/255.0 alpha:1.0];
    [shoutTextView setTextColor:brownText];

    [shoutTextView.layer setBorderColor:[redText CGColor]];

}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSString *venueName = [venueDetails objectForKey:@"name"];
    [venueNameLabel setText:venueName];
    [venueNameLabel setFont:[UIFont fontWithName:@"rockwell-bold" size:30]];
    UIColor *brownText = [UIColor colorWithRed:62.0/255.0 green:43.0/255.0 blue:26.0/255.0 alpha:1.0];
    [venueNameLabel setTextColor:brownText];
    
    shoutText = @"Woah! I just unlocked a scene from the movie No Man's Land with this check in. Thanks tumbleweed!";
    shoutTextView.text = shoutText;
    NSLog(@"shoutText is %@", shoutText);
    shoutTextView.layer.cornerRadius = 10.0;
    shoutTextView.clipsToBounds = YES;
    UIColor *beigeBorder = [UIColor colorWithRed:163.0/255.0 green:151.0/255.0 blue:128.0/255.0 alpha:1.0];
    [shoutTextView.layer setBorderColor:[beigeBorder CGColor]];
    [shoutTextView.layer setBorderWidth:3.0];
    [shoutTextView setFont:[UIFont fontWithName:@"Rockwell" size:15]];
    [shoutTextView setTextColor:beigeBorder];
    [characterCounter setTextColor:[UIColor grayColor]];
    
    photoButton.layer.cornerRadius = 10.0;
    photoButton.clipsToBounds = YES;
    [photoButton.layer setBorderColor:[beigeBorder CGColor]];
    [photoButton.layer setBorderWidth:3.0];

    
}

- (void)viewDidUnload
{
    venueNameLabel = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft 
            || interfaceOrientation == UIInterfaceOrientationLandscapeRight);

}

@end
