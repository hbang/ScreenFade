#import <SpringBoard/SpringBoard.h>
#import <UIKit/UIWindow+Private.h>

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
	CGFloat duration = userDuration?userDuration.floatValue:0.15f;

	NSLog(@"--- duration : %f", duration); 

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

	if(direction)
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC), dispatch_get_current_queue(), animation);
	else
		animation();
}


//SBDeviceLockStateChangedNotification, userInfo = @{kSBNotificationKeyState : 1 (locked) | 0 (unlocked)}
%hook SBUIController
-(void)_deviceLockStateChanged:(NSNotification *)changed{
	if([[changed.userInfo objectForKey:@"kSBNotificationKeyState"] boolValue])
		HBSFFadeScreen(YES, ^{ %orig; });
	else
		HBSFFadeScreen(NO, ^{ %orig; });
}
%end


/*
%hook SBFadeAnimationSettings
//@property(assign, nonatomic) float backlightFadeDuration;

-(void)setDefaultValues{
	%orig;

	NSNumber *userDuration = [[NSDictionary dictionaryWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/ws.hbang.screenfade.plist"]] objectForKey:@"userDuration"];
	self.backlightFadeDuration = userDuration?userDuration.floatValue:0.15f;
}

%end*/

/*
 iOS 7 and above 
%hook SBLockStateAggregator

//Only works for unlocking from ls
-(void)_updateLockState{
	if([self lockState] == 0)
		HBSFFadeScreen(YES, ^{%orig;});
	else
		%orig;
}

%end

%hook SBUIController

 iOS 6 and below 
-(void)lockFromSource:(NSInteger)source{
	if([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0){
		HBSFFadeScreen(NO, ^{
			%orig;
		});
	}

	else
		%orig;
}//end lockfromsource

%end

%hook SBAwayView

-(void)setDimmed:(BOOL)dimmed{
	if([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)
		if(!dimmed)
			HBSFFadeScreen(YES, nil);
	
	%orig;
}//end setdimmed

%end*/
