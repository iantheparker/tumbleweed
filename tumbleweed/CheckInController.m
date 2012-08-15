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
    ASIFormDataRequest *request = [Foursquare checkInFoursquare:[venueDetails objectForKey:@"id"] shout:shoutText];
    [request setDelegate:self];
    [request startAsynchronous];
    
}

#pragma mark ASIHTTPRequest Protocol

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSString *responseString = [request responseString];
    NSError *err;
    if ([[request.userInfo valueForKey:@"operation"] isEqualToString:@"checkin"]) {
        NSDictionary *checkinResponse = [NSDictionary dictionaryWithJSONString:responseString error:&err];
        sceneControllerId.scene.checkInResponse = checkinResponse;
        NSLog(@"checkin id %@", [[[checkinResponse objectForKey:@"response"] objectForKey:@"checkin"]  objectForKey:@"id"]);
        [self dismissModalViewControllerAnimated:YES];
        [sceneControllerId animateRewards];
        //NSLog(@"checkin response %@", checkinResponse);
        
    }    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"error! %@", error);
    // Must add graceful network error like a pop-up saying, get internet!
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
