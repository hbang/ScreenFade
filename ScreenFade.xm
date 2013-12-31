#import <SpringBoard/SpringBoard.h>

@interface SBBacklightController
@property(readonly, assign, nonatomic) BOOL screenIsOff;
+(id)_sharedInstanceCreateIfNeeded:(BOOL)needed;

-(void)animateBacklightToFactor:(float)factor duration:(double)duration source:(int)source completion:(id)completion;

-(void)turnOnScreenFullyWithBacklightSource:(int)backlightSource;
-(void)setBacklightFactor:(float)factor source:(int)source;

-(void)_undimFromSource:(int)source;
-(void)setBacklightFactorPending:(float)pending;
@end

%hook SBBacklightController
-(void)animateBacklightToFactor:(float)factor duration:(double)duration source:(int)source completion:(id)completion{
	NSLog(@"--called with contents: %f, %f, %i, %@", factor, duration, source, completion);
	NSNumber *userDuration = [[NSDictionary dictionaryWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/ws.hbang.screenfade.plist"]] objectForKey:@"userDuration"];
	%orig(factor, userDuration?userDuration.doubleValue:duration, source, completion);
}
%end