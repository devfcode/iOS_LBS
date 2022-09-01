#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyLocation : NSObject

+(instancetype)sharedManager;

-(void)location_hook;

@end

NS_ASSUME_NONNULL_END
