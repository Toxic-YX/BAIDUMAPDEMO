//
//  MAPMianViewController.m
//  BaiDuMap
//
//  Created by YuXiang on 2017/6/19.
//  Copyright © 2017年 Rookie.YXiang. All rights reserved.
//

#import "MAPMianViewController.h"
#import "MAPBottomView.h"
#import "RouteAnnotation.h"

@interface MAPMianViewController ()<BMKMapViewDelegate,BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate,BMKRouteSearchDelegate>

@property (nonatomic, strong) BMKMapView *mapView;
@property (nonatomic, strong) BMKLocationService *localService;     //定位服务
@property (nonatomic, strong) BMKGeoCodeSearch *geocodesearch; //地理编码主类，用来查询、返回结果信息
@property (nonatomic, strong) BMKRouteSearch *routeSearch;  //检索对象


@property (nonatomic, weak) IBOutlet UIView *bgView;
@property (nonatomic, strong) MAPBottomView *bottomView;
@property (nonatomic, strong) UIView *topBgView;
@property (nonatomic, strong) UIButton *positioning;  // 定位
@property (nonatomic, strong) UIButton *randomBtn;  //
@property (nonatomic, strong) UIButton *planningLineBtn;  // 导航路线按钮

//  储存值用变量
@property (nonatomic, assign) CGFloat currentUserLongitude;  // 当前用户所在的经度
@property (nonatomic, assign) CGFloat currentUserLatitude;    // 当前用户所在的纬度

@property (nonatomic, assign) CGFloat randomLongitude;  // 随机出来的经度
@property (nonatomic, assign) CGFloat randomLatitude;    // 随机出来的纬度

@property (nonatomic, copy) NSString *currentLoctionName;       // 当前地点
@property (nonatomic, copy) NSString *destinationLoctionName;  // 目的地地点
@end

@implementation MAPMianViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [_bgView addSubview:self.mapView];
    [self mapSomeHandle];
    
    self.topBgView.alpha = 0.0;
    [self.view addSubview:self.topBgView];
    // 底部视图
    [self.view addSubview:self.bottomView];
    
    _geocodesearch = [[BMKGeoCodeSearch alloc] init];
    _geocodesearch.delegate = self;
    // 定位按钮
    [self.topBgView addSubview:self.positioning];
    // 随机定位点经纬度按钮
    [self.topBgView addSubview:self.randomBtn];
    // 导航路线按钮
    [self.topBgView addSubview:self.planningLineBtn];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.mapView.delegate = self;  // 此处记得不用的时候需要置nil，否则影响内存的释放
    
    //初始化检索对象
    _routeSearch = [[BMKRouteSearch alloc] init];
    _routeSearch.delegate = self;
    
    // 添加一个PointAnnotation
    BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
    CLLocationCoordinate2D coor;
    coor.latitude = 39.915;
    coor.longitude = 116.404;
    annotation.coordinate = coor;
    annotation.title = @"这里是北京";
    [self.mapView addAnnotation:annotation];
    if (annotation != nil) {
        [_mapView removeAnnotation:annotation];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.mapView viewWillDisappear];
    self.mapView.delegate = nil; // 不用时，置nil
    _routeSearch.delegate = nil; // 不用时，置nil
    _geocodesearch.delegate = nil; // 不用时，置nil
}
#pragma mark - Private Methods

- (void)mapSomeHandle {
//    _mapView.mapType = BMKMapTypeNone;//设置地图为空白类型
//    [_mapView setMapType:BMKMapTypeSatellite];//切换为卫星图
//    [_mapView setMapType:BMKMapTypeStandard];//切换为普通地图
    
    [_mapView setTrafficEnabled:YES]; //打开实时路况图层
    self.mapView.baseIndoorMapEnabled = YES;//打开室内图
    self.mapView.userTrackingMode = BMKUserTrackingModeFollow;// 定位状态
    self.mapView.zoomLevel = 19;//地图显示比例
  
}

- (void)startLocation {
    self.localService.delegate = self;
    self.mapView.showsUserLocation = YES; // 显示定位图层
    self.localService.desiredAccuracy = kCLLocationAccuracyBest;
    [self.localService startUserLocationService]; //用户开始定位
}

- (void)showTopBgView {
    [UIView animateWithDuration:1.0 animations:^{
        self.topBgView.alpha = 1.0;
    }];
}

- (void)hideTopBgView {
    [UIView animateWithDuration:1.0 animations:^{
        self.topBgView.alpha = 0.0;
    }];
}

//检索提示
-(void)showGuide
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"检索提示"
                                                    message:@"检索地址有岐义，请重新输入。"
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}

//根据polyline设置地图范围
- (void)mapViewFitPolyLine:(BMKPolyline *) polyLine {
    CGFloat ltX, ltY, rbX, rbY;
    if (polyLine.pointCount < 1) {
        return;
    }
    BMKMapPoint pt = polyLine.points[0];
    ltX = pt.x, ltY = pt.y;
    rbX = pt.x, rbY = pt.y;
    for (int i = 1; i < polyLine.pointCount; i++) {
        BMKMapPoint pt = polyLine.points[i];
        if (pt.x < ltX) {
            ltX = pt.x;
        }
        if (pt.x > rbX) {
            rbX = pt.x;
        }
        if (pt.y > ltY) {
            ltY = pt.y;
        }
        if (pt.y < rbY) {
            rbY = pt.y;
        }
    }
    BMKMapRect rect;
    rect.origin = BMKMapPointMake(ltX , ltY);
    rect.size = BMKMapSizeMake(rbX - ltX, rbY - ltY);
    [self.mapView setVisibleMapRect:rect];
    self.mapView.zoomLevel = self.mapView.zoomLevel - 0.3;
}

#pragma mark - Event Response
- (IBAction)showUI:(UIButton *)sender {
    [self showTopBgView];
}

#pragma mark - 定位
- (void)didClickedPosition:(UIButton *)sender {
    [self hideTopBgView];
    [self startLocation];
}
#pragma mark - 驾车导航路线
- (void)didPlanningLineBtn:(UIButton *)sender {
    
     [self hideTopBgView];
    
    // 起点
    BMKPlanNode *start = [[BMKPlanNode alloc] init];
    start.name = _currentLoctionName;
    start.cityName =@"南京市";
    
    // 终点
    BMKPlanNode* end = [[BMKPlanNode alloc]init];
    end.name = @"苏宁总部";
    end.cityName = @"南京市";
    
    BMKDrivingRoutePlanOption *drivingRouteSearchOption = [[BMKDrivingRoutePlanOption alloc]init];
    drivingRouteSearchOption.from = start;
    drivingRouteSearchOption.to = end;
    drivingRouteSearchOption.drivingRequestTrafficType = BMK_DRIVING_REQUEST_TRAFFICE_TYPE_NONE;//不获取路况信息
    BOOL flag = [_routeSearch drivingSearch:drivingRouteSearchOption];
    
    if (flag) {
        NSLog(@"car检索发送成功");
    } else {
        NSLog(@"car检索发送失败");
    }
}

#pragma mark - 目的地
- (void)didRandomPosition:(UIButton *)sender {
    [self hideTopBgView];
    NSLog(@"经度---%f ; 纬度--- %f ",self.currentUserLongitude,self.currentUserLatitude);

    float random = 0.1;
    self.randomLongitude = self.currentUserLongitude;
    self.randomLatitude = random + self.currentUserLatitude;
    NSLog(@"随机后的经度---%f ; 随机后的纬度--- %f ",self.randomLongitude,self.randomLatitude);
    //创建地理编码对象
    CLGeocoder *geocoder=[[CLGeocoder alloc]init];
    //创建位置
    CLLocation *location=[[CLLocation alloc]initWithLatitude:self.randomLatitude longitude:self.randomLongitude];
    //反地理编码
    __weak typeof(self) weakSelf = self;
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        //判断是否有错误或者placemarks是否为空
        if (error !=nil || placemarks.count==0) {
            NSLog(@"%@",error);
            return ;
        }
        for (CLPlacemark *placemark in placemarks) {
            //赋值详细地址
            NSLog(@"%@",placemark.name);
            _destinationLoctionName = placemark.name;
            // UI刷新
            [weakSelf.bottomView updateDestinationLbl:placemark.name];
        }
    }];
}

#pragma mark ---------------
#pragma mark - BMKMapViewDelegate
#pragma mark -显示大头针
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        newAnnotationView.pinColor = BMKPinAnnotationColorPurple;
        newAnnotationView.animatesDrop = YES;// 设置该标注点动画显示
        return newAnnotationView;
    }
    return nil;
}

#pragma mark - BMKLocationServiceDelegate
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    NSLog(@"%@",userLocation);
    //更新地图上的位置
    [self.mapView updateLocationData:userLocation];
    
    // 保存当前经纬度
    self.currentUserLongitude = userLocation.location.coordinate.longitude;
    self.currentUserLatitude = userLocation.location.coordinate.latitude;
    
    //地理反编码
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeocodeSearchOption.reverseGeoPoint = userLocation.location.coordinate;
    BOOL flag = [_geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
    if(flag){
        NSLog(@"反geo检索发送成功");
        [_localService stopUserLocationService];
    }else{
        NSLog(@"反geo检索发送失败");
    }
    //创建地理编码对象
    CLGeocoder *geocoder=[[CLGeocoder alloc]init];
    //创建位置
    CLLocation *location=[[CLLocation alloc]initWithLatitude:self.currentUserLatitude longitude:self.currentUserLongitude];
    //反地理编码
    __weak typeof(self) weakSelf = self;
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        //判断是否有错误或者placemarks是否为空
        if (error !=nil || placemarks.count==0) {
            NSLog(@"%@",error);
            return ;
        }
        for (CLPlacemark *placemark in placemarks) {
            //赋值详细地址
            NSLog(@"%@",placemark.name);
            _currentLoctionName = placemark.name;
            // UI刷新
            [weakSelf.bottomView updateLocationLbl:placemark.name];
        }
    }];
 
}

#pragma mark - BMKRouteSearchDelegate
/**
 *返回驾车路线检索结果（new）
 *@param searcher 搜索对象
 *@param result 搜索结果，类型为BMKMassTransitRouteResult
 *@param error 错误号，@see BMKSearchErrorCode
 */
- (void)onGetDrivingRouteResult:(BMKRouteSearch*)searcher result:(BMKDrivingRouteResult*)result errorCode:(BMKSearchErrorCode)error
{
    NSLog(@"onGetDrivingRouteResult error:%d", (int)error);
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    array = [NSArray arrayWithArray:_mapView.overlays];
    [_mapView removeOverlays:array];
    if (error == BMK_SEARCH_NO_ERROR) {
        BMKDrivingRouteLine* plan = (BMKDrivingRouteLine*)[result.routes objectAtIndex:0];
        // 计算路线方案中的路段数目
        NSInteger size = [plan.steps count];
        int planPointCounts = 0;
        for (int i = 0; i < size; i++) {
            BMKDrivingStep* transitStep = [plan.steps objectAtIndex:i];
            if(i==0){
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = plan.starting.location;
                item.title = @"起点";
                item.type = 0;
                [_mapView addAnnotation:item]; // 添加起点标注
                
            }
            if(i==size-1){
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = plan.terminal.location;
                item.title = @"终点";
                item.type = 1;
                [_mapView addAnnotation:item]; // 添加起点标注
            }
            //添加annotation节点
            RouteAnnotation* item = [[RouteAnnotation alloc]init];
            item.coordinate = transitStep.entrace.location;
            item.title = transitStep.entraceInstruction;
            item.degree = transitStep.direction * 30;
            item.type = 4;
            [_mapView addAnnotation:item];
            
            NSLog(@"%@   %@    %@", transitStep.entraceInstruction, transitStep.exitInstruction, transitStep.instruction);
            
            //轨迹点总数累计
            planPointCounts += transitStep.pointsCount;
        }
        // 添加途经点
        if (plan.wayPoints) {
            for (BMKPlanNode* tempNode in plan.wayPoints) {
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item = [[RouteAnnotation alloc]init];
                item.coordinate = tempNode.pt;
                item.type = 5;
                item.title = tempNode.name;
                [_mapView addAnnotation:item];
            }
        }
        //轨迹点
        BMKMapPoint * temppoints = new BMKMapPoint[planPointCounts];
        int i = 0;
        for (int j = 0; j < size; j++) {
            BMKDrivingStep* transitStep = [plan.steps objectAtIndex:j];
            int k=0;
            for(k=0;k<transitStep.pointsCount;k++) {
                temppoints[i].x = transitStep.points[k].x;
                temppoints[i].y = transitStep.points[k].y;
                i++;
            }
            
        }
        // 通过points构建BMKPolyline
        BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:temppoints count:planPointCounts];
        [_mapView addOverlay:polyLine]; // 添加路线overlay
        delete []temppoints;
        [self mapViewFitPolyLine:polyLine];
    } else if (error == BMK_SEARCH_AMBIGUOUS_ROURE_ADDR) {
        //检索地址有歧义,返回起点或终点的地址信息结果：BMKSuggestAddrInfo，获取到推荐的poi列表
        NSLog(@"检索地址有岐义，请重新输入。");
        [self showGuide];
    }
}

#pragma mark 根据overlay生成对应的View
-(BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay{
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:1];
        polylineView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
        polylineView.lineWidth = 3.0;
        return polylineView;
    }
    return nil;
}


#pragma mark - Getters And Setters
- (BMKLocationService *)localService {
  if (!_localService) {
    _localService = [[BMKLocationService alloc] init];
  }
  return _localService;
}

- (BMKMapView *)mapView {
    if (!_mapView) {
        _mapView = [[BMKMapView alloc] initWithFrame:self.view.bounds];
    }
    return _mapView;
}

- (UIView *)topBgView {
    if (!_topBgView) {
        _topBgView = [[UIView alloc] initWithFrame:CGRectMake(0, kTop, kScreenW, 200)];
        _topBgView.backgroundColor = [UIColor greenColor];
    }
    return _topBgView;
}

- (MAPBottomView *)bottomView {
    if (!_bottomView) {
        CGRect rect = CGRectMake(0, kScreenH * 0.9,kScreenW,  kScreenH * 0.1);
        _bottomView = [[MAPBottomView alloc] initWithFrame:rect currentLocStr:@"当前位置:" destination:@"目的地:"];
    }
    return _bottomView;
}

- (UIButton *)positioning {
    if (!_positioning) {
        _positioning = [UIButton buttonWithType:UIButtonTypeCustom];
        _positioning.frame = CGRectMake(kMargin, 15, kButtonWidth, 30);
        _positioning.tintColor = [UIColor blackColor];
        _positioning.backgroundColor = [UIColor darkGrayColor];
        [_positioning setTitle:@"定位" forState:UIControlStateNormal];
        [_positioning addTarget:self action:@selector(didClickedPosition:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _positioning;
}

- (UIButton *)randomBtn {
    if (!_randomBtn) {
        _randomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _randomBtn.frame = CGRectMake(CGRectGetMaxX(self.positioning.frame) + 5, 15, kButtonWidth, 30);
        _randomBtn.tintColor = [UIColor blackColor];
        _randomBtn.backgroundColor = [UIColor darkGrayColor];
        [_randomBtn setTitle:@"随机地点" forState:UIControlStateNormal];
        [_randomBtn addTarget:self action:@selector(didRandomPosition:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _randomBtn;
}

- (UIButton *)planningLineBtn {
    if (!_planningLineBtn) {
        _planningLineBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _planningLineBtn.frame = CGRectMake(CGRectGetMaxX(self.randomBtn.frame) + 5, 15, kButtonWidth, 30);
        _planningLineBtn.tintColor = [UIColor blackColor];
        _planningLineBtn.backgroundColor = [UIColor darkGrayColor];
        [_planningLineBtn setTitle:@"导航路线" forState:UIControlStateNormal];
        [_planningLineBtn addTarget:self action:@selector(didPlanningLineBtn:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _planningLineBtn;
}
@end
