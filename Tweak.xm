#import "Tweak.h"

static BOOL deviceLocked, isEnabled, lpmLocked, lpmBattery, lpmBatteryLocked, lpmCharging, apBattery, apBatteryLocked, apCharging, alLPM, alCharging;
static int lpmBatteryLevel, apBatteryLevel;

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
	[battery updateLPM];
	[battery updateAP];
}
%end

%hook SBBacklightController
-(void)_autoLockTimerFired:(id)timer {
	_CDBatterySaver *saver = [_CDBatterySaver batterySaver];
	int lpm = [saver getPowerMode];

	SBUIController *battery = [%c(SBUIController) sharedInstance];
	BOOL deviceCharging = [battery isOnAC];

	if (alLPM && lpm == 1) return;
	if (alCharging && deviceCharging) return;

	%orig(timer);
}
%end


%hook SBUIController

-(void)updateBatteryState:(id)state {
	%orig;

	if (!isEnabled) return;

	SBUIController *battery = [%c(SBUIController) sharedInstance];
	[battery updateLPM];
	[battery updateAP];
}

%new
-(void)updateLPM {

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

%new
-(void)updateAP {

	RadiosPreferences *preferences = [[%c(RadiosPreferences) alloc] init];
	BOOL ap = [preferences airplaneMode];

	SBUIController *battery = [%c(SBUIController) sharedInstance];
	int batteryLevel = [battery batteryCapacityAsPercentage];
	BOOL deviceCharging = [battery isOnAC];

	// ----- ENABLE AP ----- //

	if (apCharging && deviceCharging) {
		if (!ap) {
			[preferences setAirplaneMode:YES];
			[preferences synchronize];
		}
		return;
	}

	if (apBattery && batteryLevel <= apBatteryLevel && (!apBatteryLocked || (apBatteryLocked && deviceLocked))) {
		if (!ap) {
			[preferences setAirplaneMode:YES];
			[preferences synchronize];
		}
		return;
	}

	// ----- DISABLE AP ----- //

	if (apBattery && (batteryLevel > apBatteryLevel || (apBatteryLocked && !deviceLocked))) {
		if (ap) {
			[preferences setAirplaneMode:NO];
			[preferences synchronize];
		}
		return;
	}

	if (apCharging && !deviceCharging) {
		if (ap) {
			[preferences setAirplaneMode:NO];
			[preferences synchronize];
		}
		return;
	}

}
%end

static void loadPrefs() {
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.noisyflake.smartlowpowerprefs.plist"];

	if (prefs) {
		isEnabled = ( [prefs objectForKey:@"tweakEnabled"] ? [[prefs objectForKey:@"tweakEnabled"] boolValue] : YES );

		lpmLocked = ( [prefs objectForKey:@"lpmLocked"] ? [[prefs objectForKey:@"lpmLocked"] boolValue] : NO );
		lpmBattery = ( [prefs objectForKey:@"lpmBattery"] ? [[prefs objectForKey:@"lpmBattery"] boolValue] : YES );
		lpmBatteryLevel = ( [prefs objectForKey:@"lpmBatteryLevel"] ? [[prefs objectForKey:@"lpmBatteryLevel"] integerValue] : 20 );
		lpmBatteryLocked = ( [prefs objectForKey:@"lpmBatteryLocked"] ? [[prefs objectForKey:@"lpmBatteryLocked"] boolValue] : NO );
		lpmCharging = ( [prefs objectForKey:@"lpmCharging"] ? [[prefs objectForKey:@"lpmCharging"] boolValue] : NO );

		apBattery = ( [prefs objectForKey:@"apBattery"] ? [[prefs objectForKey:@"apBattery"] boolValue] : NO );
		apBatteryLevel = ( [prefs objectForKey:@"apBatteryLevel"] ? [[prefs objectForKey:@"apBatteryLevel"] integerValue] : 10 );
		apBatteryLocked = ( [prefs objectForKey:@"apBatteryLocked"] ? [[prefs objectForKey:@"apBatteryLocked"] boolValue] : NO );
		apCharging = ( [prefs objectForKey:@"apCharging"] ? [[prefs objectForKey:@"apCharging"] boolValue] : NO );

		alLPM = ( [prefs objectForKey:@"alLPM"] ? [[prefs objectForKey:@"alLPM"] boolValue] : NO );
		alCharging = ( [prefs objectForKey:@"alCharging"] ? [[prefs objectForKey:@"alCharging"] boolValue] : NO );
	}

	[prefs release];

	if (isEnabled) {
		SBUIController *battery = [%c(SBUIController) sharedInstanceIfExists];
		[battery updateLPM];
		[battery updateAP];
	}

}

static void initPrefs() {
	// Copy the default preferences file when the actual preference file doesn't exist
	NSString *path = @"/User/Library/Preferences/com.noisyflake.smartlowpowerprefs.plist";
	NSString *pathDefault = @"/Library/PreferenceBundles/SmartLowPowerPrefs.bundle/defaults.plist";
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:path]) {
		[fileManager copyItemAtPath:pathDefault toPath:path error:nil];
	}
}

%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.noisyflake.smartlowpowerprefs/prefsupdated"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	initPrefs();
	loadPrefs();
}
