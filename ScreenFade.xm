#import <SpringBoard/SpringBoard.h>
#import <UIKit/UIWindow+Private.h>

@interface SBBacklightController
+(instancetype)sharedInstance;
-(void)animateBacklightToFactor:(float)factor duration:(double)duration source:(int)source completion:(id)completion;
@end

/* iOS 7 and above */
%hook SBBacklightController
BOOL backlighting;

-(void)animateBacklightToFactor:(float)factor duration:(double)duration source:(int)source completion:(void (^)(void))completion{
	if(factor > 0.f && factor < 1.f)
		%orig;

	if(backlighting)
		return;

	backlighting = YES;
	UIWindow *fadeWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	fadeWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	fadeWindow.backgroundColor = [UIColor blackColor];
	fadeWindow.alpha = (factor == 0.f)?0.f:1.f;
	fadeWindow.userInteractionEnabled = NO;
	fadeWindow.windowLevel = UIWindowLevelAlert + 10.f;
	fadeWindow.hidden = NO;

	NSNumber *userDuration = [[NSDictionary dictionaryWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/ws.hbang.screenfade.plist"]] objectForKey:@"userDuration"];

	[UIView animateWithDuration:(userDuration?userDuration.floatValue:duration) animations:^{
		fadeWindow.alpha = (fadeWindow.alpha == 0.f)?1.f:0.f;
	} completion:^(BOOL finished) {
		if(fadeWindow.alpha == 0)
			%orig(0.f, 0.0, source, completion);
		else
			%orig(1.f, 0.0, source, completion);

		fadeWindow.hidden = YES;
		[fadeWindow release];

		backlighting = NO;
	}];
}//end animate
%end

/* iOS 6 and below */
BOOL isAnimating = NO;
void HBSFFadeScreen(BOOL direction, void(^callback)(void)) {
	if(isAnimating) 
		return;

	isAnimating = YES;

	UIWindow *fadeWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	fadeWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	fadeWindow.backgroundColor = [UIColor blackColor];
	fadeWindow.alpha = direction?1.f:0.f;
	fadeWindow.userInteractionEnabled = NO;
	fadeWindow.windowLevel = UIWindowLevelAlert + 10.f;
	fadeWindow.hidden = NO;

	NSNumber *userDuration = [[NSDictionary dictionaryWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/ws.hbang.screenfade.plist"]] objectForKey:@"userDuration"];

	void (^animation)(void) = ^{
		[UIView animateWithDuration:(userDuration?userDuration.floatValue:0.5f) animations:^{
		fadeWindow.alpha = direction?0.f:1.f;
		
		} completion:^(BOOL finished) {
			fadeWindow.hidden = YES;
			[fadeWindow release];

			if(callback)
				callback();

			isAnimating = NO;
		}];
	};

	if(direction)
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC), dispatch_get_current_queue(), animation);
	else
		animation();
}//end fadescreen

%hook SBUIController
-(void)lockFromSource:(NSInteger)source{
	if([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)
		HBSFFadeScreen(NO, ^{ %orig; });
	else
		%orig;
}//end lockfromsource
%end

%hook SBAwayView
-(void)setDimmed:(BOOL)dimmed{
	%orig;

	if([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0 && !dimmed)
		HBSFFadeScreen(YES, nil);
}//end setdimmed
%end