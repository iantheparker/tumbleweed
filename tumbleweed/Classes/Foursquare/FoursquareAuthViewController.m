//
//  FoursquareAuthViewController.m
//  CoreDataTalk
//
//  Created by Anoop Ranganath on 2/19/11.
//  Copyright 2011 foursquare. All rights reserved.
//

#import "FoursquareAuthViewController.h"

@implementation FoursquareAuthViewController

@synthesize webView, loadingView, containerView;

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


- (void)viewDidLoad
{
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"access_token"]) [self dismissModalViewControllerAnimated:NO];
    [super viewDidLoad];
    
    NSString *authenticateURLString = [NSString stringWithFormat:@"https://foursquare.com/oauth2/authenticate?client_id=%@&response_type=token&redirect_uri=%@", [[Environment sharedInstance] foursquare_client_id], [[Environment sharedInstance] callback_url] ];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:authenticateURLString]];
    [webView loadRequest:request];
    NSLog(@"web auth url %@", authenticateURLString);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.webView = nil;
}

#pragma mark - Web view delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([request.URL.scheme isEqualToString:@"itms-apps"]) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [activityIndicator stopAnimating];
    [loadingLabel removeFromSuperview];
    NSString *URLString = [[self.webView.request URL] absoluteString];
    NSLog(@"--> %@", URLString);
    if ([URLString rangeOfString:@"access_token="].location != NSNotFound) {
        NSString *accessToken = [[URLString componentsSeparatedByString:@"="] lastObject];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:accessToken forKey:@"access_token"];
        [defaults synchronize];
       // if we want a web splash "succes page" 
        NSLog(@"got access token, closing modal %@", accessToken);
        [self dismissModalViewControllerAnimated:YES];
        [[Tumbleweed sharedClient] performSelectorInBackground:@selector(registerUser) withObject:nil];
    } 
    else NSLog(@"no access token, ignoring");
}

- (IBAction) dismissModal:(id)sender
{
    NSLog(@"cancelling Foursquare Connect");
    [self dismissModalViewControllerAnimated:YES];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
