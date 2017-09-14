#import "FSSwitchDataSource.h"
#import "FSSwitchPanel.h"
#import <Preferences/PSSpecifier.h>

static NSString *nsDomainString = @"/var/mobile/Library/Preferences/com.noisyflake.smartlowpowerprefs.plist";
static NSString *nsNotificationString = @"com.noisyflake.smartlowpowerprefs/prefsupdated";

@interface SmartLowPowerFSSwitch : NSObject <FSSwitchDataSource>
@end

@interface _CDBatterySaver : NSObject
+ (id)batterySaver;
- (int)setMode:(int)arg1;
@end

@implementation SmartLowPowerFSSwitch

- (NSString *)titleForSwitchIdentifier:(NSString *)switchIdentifier {
	return @"SmartLowPower";
}

- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier {
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:nsDomainString];
	BOOL isEnabled = ( [prefs objectForKey:@"tweakEnabled"] ? [[prefs objectForKey:@"tweakEnabled"] boolValue] : YES );
	return (isEnabled) ? FSSwitchStateOn : FSSwitchStateOff;
}

- (void)applyState:(FSSwitchState)newState forSwitchIdentifier:(NSString *)switchIdentifier {
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:nsDomainString];

	switch (newState) {
	case FSSwitchStateIndeterminate:
		return;
	case FSSwitchStateOn:
		[prefs setObject:@YES forKey:@"tweakEnabled"];
		break;
	case FSSwitchStateOff:
		[prefs setObject:@NO forKey:@"tweakEnabled"];
		BOOL enableLPM = ( [prefs objectForKey:@"fsLPM"] ? [[prefs objectForKey:@"fsLPM"] boolValue] : NO );
		if (enableLPM) {
			_CDBatterySaver *saver = [_CDBatterySaver batterySaver];
			[saver setMode:1];
		}
		break;
	}

	[prefs writeToFile:nsDomainString atomically:YES];

	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)nsNotificationString, NULL, NULL, YES);
	return;
}

@end
