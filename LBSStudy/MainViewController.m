//
//  MainViewController.m
//  LBSStudy
//
//  Created by Dio Brand on 2022/7/19.
//

#import "MainViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MyLocation.h"

@interface MainViewController ()<MKMapViewDelegate,CLLocationManagerDelegate>

/** 地图对象 */
@property(nonatomic, strong)MKMapView * mapView;
/** 定位管理者 */
@property(nonatomic, strong)CLLocationManager * locationManager;

@property(nonatomic,copy)NSString *locationString;

@end

@implementation MainViewController

/** 懒加载地图视图 */
- (MKMapView *)mapView{
    if (_mapView == nil) {
        _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        /** 设置地图类型 */
        _mapView.mapType = MKMapTypeStandard;
        //设置地图可缩放
        _mapView.zoomEnabled = YES;
        //设置地图可滚动
        _mapView.scrollEnabled = YES;
        //设置地图可旋转
        _mapView.rotateEnabled = YES;
        //设置显示用户显示位置
        _mapView.showsUserLocation = YES;
        //为MKMapView设置delegate
        _mapView.delegate = self;
    }
    return _mapView;
}

- (CLLocationManager *)locationManager{
    if (_locationManager == nil) {
        _locationManager = [[CLLocationManager alloc] init];
        /** 导航类型 */
        _locationManager.activityType = CLActivityTypeFitness;
        /** 设置代理, 非常关键 */
        _locationManager.delegate = self;
        /** 想要定位的精确度, kCLLocationAccuracyBest:最好的 */
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        /** 获取用户的版本号 */
        if([[UIDevice currentDevice].systemVersion floatValue] >= 8.0){
            [_locationManager requestAlwaysAuthorization];
        }
        /** 允许后台获取用户位置(iOS9.0) */
        if([[UIDevice currentDevice].systemVersion floatValue] >= 9.0){
            // 一定要勾选后台模式 location updates 否者程序奔溃
            _locationManager.allowsBackgroundLocationUpdates = YES;
        }
    }
    return _locationManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    [[MyLocation sharedManager] location_hook];
    //添加地图视图到控制器
    [self.view addSubview:self.mapView];
    
    /** 申请授权, AlwaysAuthorization:永久授权 */
    [self.locationManager requestAlwaysAuthorization];
    
    /** 开始更新位置信息, 调用这个方法后, 才有代理回调 */
    [self.locationManager startUpdatingLocation];
}

/** 地址解析, 把地址字符串转成坐标值 */
- (void)geocodingAddress{
    NSLog(@"%s  ---> go here",__FUNCTION__);
    /** 把省会的名字做地址解析 */
    CLGeocoder * coder = [[CLGeocoder alloc] init];
    [coder geocodeAddressString:self.locationString completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        CLPlacemark * placemark = placemarks.lastObject;
        CLLocationCoordinate2D coor = placemark.location.coordinate;
        
        /** 回到主线程刷新UI界面 */
        dispatch_async(dispatch_get_main_queue(), ^{
            
            /** 设置当前位置的图钉, MKPointAnnotation:采用MKAnnotation协议的对象, pinView:系统图钉 */
            MKPointAnnotation * point = [[MKPointAnnotation alloc] init];
            point.coordinate = coor;
            /** 添加锚点, 这个方法会调用下面的 设置锚点视图 */
            [self.mapView addAnnotation:point];
            
            /** 将地图的显示区域变小 */
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coor, 1000, 1000);
            [self.mapView setRegion:region animated:YES];
        });
        
    }];
    
}

#pragma mark - 定位代理
/** 更新位置信息后的回调, 这个方法会重覆调用 */
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    NSLog(@"%s  ---> go here",__FUNCTION__);
    /** 获取到当前位置 */
    CLLocation * currLocation = locations.lastObject;
    double lat = currLocation.coordinate.latitude;
    double lon = currLocation.coordinate.longitude;
    NSLog(@"lat:%17.15f, lon:%17.14f",lat,lon);
    
    /*
     北京
     39.908722 116.397499
     曼谷
     13.755241915225557, 100.50263978153538
     **/
    //    double new_latitude = 13.755241915225557;
    //    double new_longitude = 100.50263978153538;
    //    CLLocation *currLocation = [[CLLocation alloc] initWithLatitude:new_latitude longitude:new_longitude];
    
    /* 设置当前位置的图钉, MKPointAnnotation:采用MKAnnotation协议的对象, pinView:系统图钉 */
    MKPointAnnotation * point = [[MKPointAnnotation alloc] init];
    point.coordinate = currLocation.coordinate;
    /* 位置信息, 地址反向解析, 得到位置的名称 */
    CLGeocoder * coder = [[CLGeocoder alloc] init];
    [coder reverseGeocodeLocation:currLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        CLPlacemark * placemark = placemarks.lastObject;
        point.title = [NSString stringWithFormat:@"当前:%@", placemark.name];
    }];
    /* 添加图钉, 这个方法会调用下面的 代理方法 */
    [self.mapView addAnnotation:point];
    
    /* 将地图的显示区域变小 */
    /*
     MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(currLocation.coordinate, 1000, 1000);
     [self.mapView setRegion:region animated:YES];
     */
}

#pragma mark - 地图代理
/** 设置锚点视图 */
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    NSLog(@"%s  ---> go here",__FUNCTION__);
    MKPinAnnotationView * pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"pinView"];
    if (pinView == nil) {
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pinView"];
    }
    pinView.animatesDrop = YES;
    pinView.canShowCallout = YES;
    
    return pinView;
}


@end
