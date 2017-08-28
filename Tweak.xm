#import "Tweak.h"

static BOOL deviceLocked, isEnabled, lpmLocked, lpmBattery, lpmBatteryLocked, lpmCharging;
static int lpmBatteryLevel;

%hook SpringBoard
-(void)frontDisplayDidChange:(id)newDisplay {
	%orig(newDisplay);

	if (!isEnabled) return;

	if ([newDisplay isKindOfClass:%c(SBDashBoardViewController)] ||
		[newDisplay isKindOfClass:%c(SBLockScreenViewController)]) {
		deviceLocked = YES;
	} else {
		deviceLocked = NO;
	}

	SBUIController *battery = [%c(SBUIController) sharedInstance];
	[battery updateSLP];
}
%end


%hook SBUIController

-(void)updateBatteryState:(id)state {
	%orig;

	if (!isEnabled) return;

	SBUIController *battery = [%c(SBUIController) sharedInstance];
	[battery updateSLP];

	// RadiosPreferences *preferences = [[%c(RadiosPreferences) alloc] init];
 //	[preferences setAirplaneMode:YES];
 //	[preferences synchronize];
}

%new
-(void)updateSLP {

	_CDBatterySaver *saver = [_CDBatterySaver batterySaver];
	int lpm = [saver getPowerMode];

	SBUIController *battery = [%c(SBUIController) sharedInstance];
	int batteryLevel = [battery batteryCapacityAsPercentage];
	BOOL deviceCharging = [battery isOnAC];

	// ----- ENABLE LPM ----- //

	if (lpmCharging && deviceCharging) {
		if (lpm == 0) [saver setMode:1];
		return;
	}

	if (lpmBattery && batteryLevel <= lpmBatteryLevel && (!lpmBatteryLocked || (lpmBatteryLocked && deviceLocked))) {
		if (lpm == 0) [saver setMode:1];
		return;
	}

	if (lpmLocked && deviceLocked) {
		if (lpm == 0) [saver setMode:1];
		return;
	}

	// ----- DISABLE LPM ----- //

	if (lpmBattery && (batteryLevel > lpmBatteryLevel || (lpmBatteryLocked && !deviceLocked))) {
		if (lpm == 1) [saver setMode:0];
		return;
	}

	if (lpmLocked && !deviceLocked) {
		if (lpm == 1) [saver setMode:0];
		return;
	}

	if (lpmCharging && !deviceCharging) {
		if (lpm == 1) [saver setMode:0];
		return;
	}

}
%end

static void loadPrefs() {
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.noisyflake.smartlowpowerprefs.plist"];

	if (prefs) {
		isEnabled = ( [prefs objectForKey:@"tweakEnabled"] ? [[prefs objectForKey:@"tweakEnabled"] boolValue] : YES );
		lpmLocked = ( [prefs objectForKey:@"lpmLocked"] ? [[prefs objectForKey:@"lpmLocked"] boolValue] : NO );
		lpmBattery = ( [prefs objectForKey:@"lpmBattery"] ? [[prefs objectForKey:@"lpmBattery"] boolValue] : NO );
		lpmBatteryLevel = [[prefs objectForKey:@"lpmBatteryLevel"] integerValue];
		lpmBatteryLocked = ( [prefs objectForKey:@"lpmBatteryLocked"] ? [[prefs objectForKey:@"lpmBatteryLocked"] boolValue] : NO );
		lpmCharging = ( [prefs objectForKey:@"lpmCharging"] ? [[prefs objectForKey:@"lpmCharging"] boolValue] : NO );
	}

	[prefs release];

	SBUIController *battery = [%c(SBUIController) sharedInstanceIfExists];
	[battery updateSLP];
}

%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.noisyflake.smartlowpowerprefs/prefsupdated"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	loadPrefs();
}
