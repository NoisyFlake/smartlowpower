#import "Tweak.h"

static BOOL deviceLocked, isEnabled, lpmLocked, lpmBattery, lpmBatteryLocked, lpmCharging;
static int lpmBatteryLevel;

%hook SpringBoard
-(void)frontDisplayDidChange:(id)newDisplay {
  %orig(newDisplay);

  if (!isEnabled) return;

  _CDBatterySaver *saver = [_CDBatterySaver batterySaver];
  int lpm = [saver getPowerMode];

  SBUIController *battery = [%c(SBUIController) sharedInstance];
  int batteryLevel = [battery batteryCapacityAsPercentage];
  BOOL isCharging = [battery isOnAC];

	if ([newDisplay isKindOfClass:%c(SBDashBoardViewController)] ||
		[newDisplay isKindOfClass:%c(SBLockScreenViewController)]) {
		/* Device is now locked.
		   Activate LPM when:
		   - LPMLocked = ON
		   - LPMBattery = ON & LPMBatteryLock = ON & BatteryLevel <= LPMBatteryLevel
		*/
		if (lpmLocked || (lpmBattery && lpmBatteryLocked && batteryLevel <= lpmBatteryLevel)) {
			if (lpm == 0) [saver setMode:1];
		}
	} else {
		/* Device is now unlocked.
		   Deactivate LPM when:
		   - LPMLocked = ON
		   - LPMBattery = ON & LPMBatteryLock = ON
		   Exceptions:
		   - LPMCharging = ON & Device is charging
		   - LPMLocked = ON & LPMBattery = ON & LPMBatteryLocked = OFF & BatteryLevel <= LPMBatteryLevel
		   ---- Basically means ignore LPMLocked when LPMBattery would cause LPM activation
		*/
		if (lpmLocked || (lpmBattery && lpmBatteryLocked)) {
			if ((lpmLocked && lpmBattery && !lpmBatteryLocked && batteryLevel <= lpmBatteryLevel) ||
					(lpmCharging && isCharging)) return;

			if (lpm == 1) [saver setMode:0];
		}
	}
}
%end


%hook SBUIController

-(void)updateBatteryState:(id)arg1 {
	%orig;

	if (!isEnabled) return;

	 _CDBatterySaver *saver = [_CDBatterySaver batterySaver];
  int lpm = [saver getPowerMode];

  SBUIController *battery = [%c(SBUIController) sharedInstance];
  int batteryLevel = [battery batteryCapacityAsPercentage];
  BOOL isCharging = [battery isOnAC];

  NSLog(@"Battery at: %d percent, LPM at %d percent", batteryLevel, lpmBatteryLevel);

  if ((!lpmBatteryLocked && batteryLevel <= lpmBatteryLevel) || (lpmCharging && isCharging)) {
  	if (lpm == 0) [saver setMode:1];
	} else if ((!lpmBatteryLocked && batteryLevel > lpmBatteryLevel) && (!lpmCharging || (lpmCharging && !isCharging))) {
		if (lpm == 1) [saver setMode:0];
	}

	// TODO: Set variable for on lockscreen and do everything else here.


	// RadiosPreferences *preferences = [[%c(RadiosPreferences) alloc] init];
 //  [preferences setAirplaneMode:YES];
 //  [preferences synchronize];
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
}

%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.noisyflake.smartlowpowerprefs/prefsupdated"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	loadPrefs();
}
