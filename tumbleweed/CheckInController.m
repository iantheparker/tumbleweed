//
//  CheckInController.m
//  tumbleweed
//
//  Created by Ian Parker on 2/3/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import "CheckInController.h"

@implementation CheckInController

@synthesize venueDetails, venueNameLabel, shoutText, characterCounter, shoutTextView, sceneControllerId, publicCheckinSwitch;


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
        shoutText = @"Woah! I just unlocked a scene from the movie No Man's Land with this check in. Thanks tumbleweed!";
        shoutTextView.text = shoutText;
        NSLog(@"shoutText is %@", shoutText);
    }
    return self;
}

#pragma mark Event Handlers


- (IBAction)dismissModal:(id)sender
{
    //NSLog(@"dismissing modal");
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)checkIn:(id)sender
{
    [activityIndicator setHidden:NO];
    [activityIndicator startAnimating];
    // add publicSwitch.on to checkin method

    
    [Foursquare checkIn:[venueDetails objectForKey:@"id"] shout:shoutText WithBlock:^(NSDictionary *checkInResponse, NSError *error) {
        if (error) {
            NSLog(@"error checking in %@", error);
        }
        else {
            [self dismissViewControllerAnimated:YES completion:^{
                sceneControllerId.scene.checkInResponse = checkInResponse;
                sceneControllerId.scene.unlocked = YES;
                //this guarantees that the scene states get saved in case someone closes app before going back to tweedVC
                [[[self parentViewController] parentViewController] performSelectorInBackground:@selector(gameState) withObject:nil];
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
    characterCounter.text = [NSString stringWithFormat:@"%d", (140 - shoutTextView.text.length)];    
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
    //characterCounter.text = [NSString stringWithFormat:@"%d", (140 - shoutTextView.text.length)]; 
    
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
