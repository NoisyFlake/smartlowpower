#include "slpRootListController.h"

@implementation slpRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}

	return _specifiers;
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:path];
	return (settings[specifier.properties[@"key"]]) ?: specifier.properties[@"default"];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:path];
	[settings setObject:value forKey:specifier.properties[@"key"]];
	[settings writeToFile:path atomically:YES];
	CFStringRef notificationName = (CFStringRef)specifier.properties[@"PostNotification"];
	if (notificationName) {
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
	}
}

-(void)save
{
    [self.view endEditing:YES];
}

-(void)paypal {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=XMF6DRETENHN8&lc=US"]];
}

@end


@interface BannerCell : PSTableCell {
	UILabel *tweakName;
	UILabel *version;
}
@end

@implementation BannerCell

- (id)initWithSpecifier:(PSSpecifier *)specifier
{
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Banner" specifier:specifier];
	if (self) {
		CGFloat width = 320.0f;
		CGRect frame = CGRectMake(0.0f, -25.0f, width, 60.0f);

		tweakName = [[UILabel alloc] initWithFrame:frame];
		[tweakName layoutIfNeeded];
		tweakName.numberOfLines = 1;
		tweakName.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		tweakName.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:40.0f];
		tweakName.textColor = [UIColor colorWithRed:0.3f green:0.3f blue:0.3f alpha:1.0f];
		tweakName.shadowColor = [UIColor whiteColor];
		tweakName.shadowOffset = CGSizeMake(0.0f, 1.0f);
		tweakName.text = @"SmartLowPower";
		tweakName.backgroundColor = [UIColor clearColor];
		tweakName.textAlignment = NSTextAlignmentCenter;

		CGRect frame2 = CGRectMake(0.0f, 10.0f, width, 60.0f);
		version = [[UILabel alloc] initWithFrame:frame2];
		version.numberOfLines = 1;
		version.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		version.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f];
		version.textColor = [UIColor colorWithRed:0.3f green:0.3f blue:0.3f alpha:1.0f];
		version.shadowColor = [UIColor whiteColor];
		version.shadowOffset = CGSizeMake(0.0f, 1.0f);
		version.text = @"Version 1.0.0";
		version.backgroundColor = [UIColor clearColor];
		version.textAlignment = NSTextAlignmentCenter;

		[self addSubview:tweakName];
		[self addSubview:version];
	}
    return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)width {
	return 100.0f;
}
@end
