#import <SpringBoard/SpringBoard.h>

/* Relevant Method Forward-Declare */
@interface SBBacklightController
@property(readonly, assign, nonatomic) BOOL screenIsOff;
+ (id)sharedInstance;
+ (id)sharedInstanceIfExists;
+(id)_sharedInstanceCreateIfNeeded:(BOOL)needed;

-(void)animateBacklightToFactor:(float)factor duration:(double)duration source:(int)source completion:(id)completion;

-(void)turnOnScreenFullyWithBacklightSource:(int)backlightSource;
-(void)setBacklightFactor:(float)factor source:(int)source;

-(void)_undimFromSource:(int)source;
-(void)setBacklightFactorPending:(float)pending;
@end

/* Hook To Inject Hashbang Function */
%hook SBBacklightController
static BOOL isAnimating = NO;

//locking from ls = 0, 0.5, 0, stack
-(void)animateBacklightToFactor:(float)factor duration:(double)duration source:(int)source completion:(void (^)(void))completion{
	NSLog(@"--called with contents: %f, %f, %i, %@", factor, duration, source, completion);
	if(!isAnimating){
		isAnimating = YES;

		UIWindow *fadeWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
		fadeWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		fadeWindow.backgroundColor = [UIColor blackColor];
		fadeWindow.alpha = (factor > 0.f)?0.f:1.f;
		fadeWindow.userInteractionEnabled = NO;
		fadeWindow.windowLevel = UIWindowLevelAlert + 10.f;
		fadeWindow.hidden = NO;

		NSNumber *userDuration = [[NSDictionary dictionaryWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/ws.hbang.screenfade.plist"]] objectForKey:@"userDuration"];

		[UIView animateWithDuration:(userDuration?userDuration.floatValue:duration) animations:^{
			fadeWindow.alpha = factor;
		} completion:^(BOOL finished) {

	//		if(!direction)
	//			[[%c(SBBacklightController) sharedInstance] turnOnScreenFullyWithBacklightSource:source];
	//		else
	//			[[%c(SBBacklightController) sharedInstance] setBacklightFactor:fadeWindow.alpha source:source];

			fadeWindow.hidden = YES;
			[fadeWindow release];

			%orig(factor, 0.0, source, completion);
			isAnimating = NO;
		}];
	}
}//end animate

-(void)setBacklightFactor:(float)factor source:(int)source{
	NSLog(@"set --- %f, %i", factor, source);
	%orig;
}

-(void)setBacklightFactorPending:(float)pending{
	NSLog(@"pending --- %f", pending);
	%orig;
}

%end