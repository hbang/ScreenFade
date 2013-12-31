#import <SpringBoard/SpringBoard.h>
#import <UIKit/UIWindow+Private.h>

BOOL isAnimating = NO;
static float duration;

void HBSFFadeScreen(BOOL direction, void(^callback)(void)) {
	if(isAnimating) 
		return;

	isAnimating = YES;

	NSNumber *userDuration = [[NSDictionary dictionaryWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/ws.hbang.screenfade.plist"]] objectForKey:@"userDuration"];
	duration = userDuration?userDuration.floatValue:0.15f;

	UIWindow *fadeWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	fadeWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	fadeWindow.backgroundColor = [UIColor blackColor];
	fadeWindow.alpha = direction?1.f:0.f;
	fadeWindow.userInteractionEnabled = NO;
	fadeWindow.windowLevel = UIWindowLevelAlert + 10.f;
	fadeWindow.hidden = NO;

	void (^animation)(void) = ^{
		[UIView animateWithDuration:duration animations:^{
			fadeWindow.alpha = direction?0.f:1.f;
		} completion:^(BOOL finished) {
			fadeWindow.hidden = YES;
			[fadeWindow release];

			if(callback)
				callback();

			isAnimating = NO;
		}];
	};

	if (direction)
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC), dispatch_get_current_queue(), animation);
	else
		animation();
}//end fadescreen

%hook SBUIController

-(void)lockFromSource:(NSInteger)source{
	HBSFFadeScreen(NO, ^{
		%orig;
	});
}

%end

%hook SBAwayView

-(void)setDimmed:(BOOL)dimmed{
	%orig;

	if(!dimmed)
		HBSFFadeScreen(YES, nil);
}

%end