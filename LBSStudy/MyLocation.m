#import "MyLocation.h"
#import <objc/runtime.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

// 基点经纬度
static double base_latitude;
static double base_longitude;
// 单例
static MyLocation *staticInstance = nil;
@implementation MyLocation

// 生成单例
+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticInstance = [[super allocWithZone:NULL] init]; // 与下面两个方匹配
        // 随机选择初始化经纬度
        [staticInstance setBaseLocation];
    });
    return staticInstance;
}

+(id)allocWithZone:(struct _NSZone *)zone{
    return [[self class] sharedManager];
}

-(id)copyWithZone:(struct _NSZone *)zone{
    return [[self class] sharedManager];
}

/* 设置基准 经纬度
 曼谷经纬度
 (100.403856, 100.647812)
 (13.614062,  13.842117)
 
 经纬度小数点后 第6位 大约是 0.111米
 **/
long bit_len = 1000000;
double lat_start = 13.614062;
double lat_end = 13.842117;
double lon_start = 100.403856;
double lon_end = 100.647812;
-(void)setBaseLocation {
    long range_lat = (lat_end - lat_start) * bit_len;
    int delt_lat = arc4random() % range_lat;
    base_latitude = lat_start + ((double)delt_lat / bit_len);
    
    long range_lon = (lon_end - lon_start) * bit_len;
    int delt_lon = arc4random() % range_lon;
    base_longitude = lon_start + ((double)delt_lon / bit_len);
}

// hook 后给位置的方法
-(CLLocationCoordinate2D)coordinate {
    double new_latitude =   base_latitude;
    double new_longitude = base_longitude;
    if ((arc4random() % 3) == 1) {
        int lat_random = arc4random() % 30;
        new_latitude += ((double)lat_random / bit_len);

        int lon_random = arc4random() % 30;
        new_longitude += ((double)lon_random / bit_len);
    }
    
    CLLocationCoordinate2D new_coordinate;
    new_coordinate.latitude = new_latitude;
    new_coordinate.longitude = new_longitude;
    return new_coordinate;
}

-(void)location_hook {
    //    CLLocationManager *locManager = [[CLLocationManager alloc] init];
    //    CLLocation *location = [locManager location];
    //    double lat = location.coordinate.latitude;
    //    double lon = location.coordinate.longitude;
    //    NSLog(@"lat:%f, lon:%f",lat,lon);
    //
    //    CLLocation *loc = [[CLLocation alloc]init];
    //    [loc coordinate];
    
    Method oriMethod_CLLocation = class_getInstanceMethod(objc_getClass("CLLocation"), @selector(coordinate));
    Method curMethod_CLLocation = class_getInstanceMethod(objc_getClass("MyLocation"), @selector(coordinate));
    method_exchangeImplementations(oriMethod_CLLocation, curMethod_CLLocation);
}

@end
