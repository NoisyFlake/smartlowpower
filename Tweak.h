@interface _CDBatterySaver : NSObject
+ (id)batterySaver;
- (int)getPowerMode;
- (int)setMode:(int)arg1;
@end

@interface RadiosPreferences : NSObject
- (void)setAirplaneMode:(BOOL)arg1;
- (void)synchronize;
@end

@interface SBUIController : NSObject
+(SBUIController *)sharedInstance;
+(SBUIController *)sharedInstanceIfExists;
-(BOOL)isOnAC;
-(int)batteryCapacityAsPercentage;
-(void)updateSLP;
@end
