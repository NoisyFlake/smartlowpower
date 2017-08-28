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

@end

@interface BannerCell : PSTableCell {
	UILabel *tweakName;
}
@end

@implementation BannerCell

- (id)initWithSpecifier:(PSSpecifier *)specifier
{
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Banner" specifier:specifier];
	if (self) {
		CGFloat width = 320.0f;
		CGRect frame = CGRectMake(0.0f, -20.0f, width, 60.0f);

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
		[self addSubview:tweakName];
	}
    return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)width {
	return 75.0f;
}
@end
