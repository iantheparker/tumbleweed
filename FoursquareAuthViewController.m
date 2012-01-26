//
//  FoursquareAuthViewController.m
//  CoreDataTalk
//
//  Created by Anoop Ranganath on 2/19/11.
//  Copyright 2011 foursquare. All rights reserved.
//

#import "FoursquareAuthViewController.h"
#import "Constants.h"

@implementation FoursquareAuthViewController

@synthesize webView;

- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    // removed for ARC [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib

/*.
- (void)loadView {
	self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
}
 */

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *authenticateURLString = [NSString stringWithFormat:@"https://foursquare.com/oauth2/authenticate?display=touch&client_id=%@&response_type=token&redirect_uri=%@", CLIENT_ID, CALLBACK_URL];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:authenticateURLString]];
    [webView loadRequest:request];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.webView = nil;
}

#pragma mark - Web view delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *URLString = [[self.webView.request URL] absoluteString];
    NSLog(@"--> %@", URLString);
    if ([URLString rangeOfString:@"access_token="].location != NSNotFound) {
        NSString *accessToken = [[URLString componentsSeparatedByString:@"="] lastObject];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:accessToken forKey:@"access_token"];
        [defaults synchronize];
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft
            || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

@end
