#import <Preferences/PSListController.h>
#import <UIKit/UIActivityViewController.h>
#import <Twitter/Twitter.h>
#include <notify.h>

#define URL_ENCODE(string) [(NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)(string), NULL, CFSTR(":/=,!$& '()*+;[]@#?"), kCFStringEncodingUTF8) autorelease]

@interface SFPreferencesListController : PSListController
-(void)loadView;
@end

@implementation SFPreferencesListController
-(void)loadView {
	[super loadView];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareTapped:)];
}

-(NSArray *)specifiers {
	if (!_specifiers)
		_specifiers = [[self loadSpecifiersFromPlistName:@"SFPreferences" target:self] retain];

	return _specifiers;
}

-(void)shareTapped:(UIBarButtonItem *)sender {
	NSString *text = @"Check out #ScreenFade by HASHBANG Productions!";
	NSURL *url = [NSURL URLWithString:@"http://hbang.ws/screenfade"];

	if (%c(UIActivityViewController)){
		UIActivityViewController *viewController = [[[%c(UIActivityViewController) alloc] initWithActivityItems:[NSArray arrayWithObjects:text, url, nil] applicationActivities:nil] autorelease];
		[self.navigationController presentViewController:viewController animated:YES completion:NULL];
	} else if (%c(TWTweetComposeViewController) && [TWTweetComposeViewController canSendTweet]) {
		TWTweetComposeViewController *viewController = [[[TWTweetComposeViewController alloc] init] autorelease];
		viewController.initialText = text;
		[viewController addURL:url];
		[self.navigationController presentViewController:viewController animated:YES completion:NULL];
	} else {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/intent/tweet?text=%@%%20%@", URL_ENCODE(text), URL_ENCODE(url.absoluteString)]]];
	}
}
@end
