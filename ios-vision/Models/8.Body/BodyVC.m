//
//  BodyVC.m
//  ios-vision
//
//  Created by mac on 2020/11/22.
//

#import "BodyVC.h"
#import <Vision/Vision.h>

@interface BodyVC (){
    int _imgIndex;
}

@property (nonatomic,strong) UIImageView *coverImageView;
@property (strong,nonatomic) UIButton *bodyBtn;
@property (strong,nonatomic) UIButton *handBtn;

@end

@implementation BodyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configBaseUI];
    _imgIndex=0;
}

#pragma mark - BaseSet

- (void)configBaseUI{
    [self.view addSubview:self.coverImageView];
    [self.coverImageView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(100);
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
        make.bottom.equalTo(self.view).offset(-150);
    }];
    
    [self.view addSubview:self.bodyBtn];
    [self.bodyBtn makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.coverImageView.bottom).offset(10);
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
        make.height.equalTo(40);
    }];
    
    [self.view addSubview:self.handBtn];
    [self.handBtn makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bodyBtn.bottom).offset(10);
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
        make.height.equalTo(40);
    }];
}

#pragma mark - Lazy init

- (UIImageView *)coverImageView{
    if (!_coverImageView) {
        UIImageView *imageView=[UIImageView new];
        imageView.backgroundColor=UIColor.lightGrayColor;
        imageView.contentMode=UIViewContentModeScaleAspectFit;
        imageView.clipsToBounds=YES;
        _coverImageView=imageView;
    }
    return _coverImageView;
}

- (UIButton *)bodyBtn{
    if (!_bodyBtn) {
        UIButton *button = [[UIButton alloc]init];
        [button setBackgroundImage:nil forState:UIControlStateNormal];
        [button setTitle:@"Detecting Human Body Poses in Images" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(bodyBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor=UIColor.brownColor;
        _bodyBtn = button;
    }
    return _bodyBtn;
}

- (UIButton *)handBtn{
    if (!_handBtn) {
        UIButton *button = [[UIButton alloc]init];
        [button setBackgroundImage:nil forState:UIControlStateNormal];
        [button setTitle:@"Detecting Human Hand Poses in Images" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(handBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor=UIColor.brownColor;
        _handBtn = button;
    }
    return _handBtn;
}

#pragma mark - Action

-(void)bodyBtnAction:(UIButton*)btn{
    for(CALayer *subLayer in self.coverImageView.layer.sublayers){
        [subLayer removeFromSuperlayer];
    }
    //
    _imgIndex++;
    if (_imgIndex>3){
        _imgIndex=0;
    }
    UIImage *image;
    image=[UIImage imageNamed:@"人像"];
    switch (_imgIndex) {
        case 0:
            image=[UIImage imageNamed:@"人像"];
            break;
        case 1:
            image=[UIImage imageNamed:@"人像2"];
            break;
        case 2:
            image=[UIImage imageNamed:@"人像3"];
            break;
        default:
            image=[UIImage imageNamed:@"人像4"];
            break;
    }
    
    self.coverImageView.image=image;
    CGImageRef cgImage=image.CGImage;
    //
    VNImageRequestHandler *imageRequestHandler=[[VNImageRequestHandler alloc]initWithCGImage:cgImage orientation:kCGImagePropertyOrientationUp options:@{}];
    //
    VNRequest *request;
    if (@available(iOS 14.0, *)) {
        request=[[VNDetectHumanBodyPoseRequest alloc]initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
            for(VNObservation *observation in request.results){
                if ([observation isKindOfClass:VNHumanBodyPoseObservation.class]){
                    VNHumanBodyPoseObservation *pointsObservation=(VNHumanBodyPoseObservation *)observation;
                    for (VNRecognizedPointKey pointKey in pointsObservation.availableKeys){
                        NSLog(@"PointKey:%@",pointKey);
                    }
                    for (VNRecognizedPointGroupKey pointGroupKey in pointsObservation.availableGroupKeys){
                        NSLog(@"PointGroupKey:%@",pointGroupKey);
                    }
                    for (VNHumanBodyPoseObservationJointName jointName in pointsObservation.availableJointNames){
                        NSLog(@"JointName:%@",jointName);
                    }
                    for (VNHumanBodyPoseObservationJointsGroupName jointGroupName in pointsObservation.availableJointsGroupNames){
                        NSLog(@"JointName:%@",jointGroupName);
                    }
                    NSDictionary<VNRecognizedPointKey,VNRecognizedPoint *> * pointDict=[pointsObservation recognizedPointsForGroupKey:VNRecognizedPointGroupKeyAll error:nil];
                    NSArray *keys = [pointDict allKeys];
                    NSMutableArray *pointsArg=[NSMutableArray array];
                    for (int i = 0; i < keys.count; i++){
                        VNRecognizedPointKey key = [keys objectAtIndex: i];
                        VNRecognizedPoint * point = [pointDict objectForKey: key];
                        NSLog (@"RecognizedPoint  Key:%@ , Point: { key:%@ , confidence:%f , point:[%f,%f] ,location:[%f,%f] }", key, point.identifier , point.confidence ,point.x,point.y, point.location.x, point.location.y);
                        [pointsArg addObject:[NSValue valueWithCGPoint:point.location]];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self drawAtLayer:self.coverImageView.layer cgImage:cgImage pointsArg:pointsArg];
                    });
                }
            }
        }];
    }
    //3. Perform Requests
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error;
        if ([imageRequestHandler performRequests:@[request] error:&error]){
        }
    });
}

-(void)handBtnAction:(UIButton*)btn{
    for(CALayer *subLayer in self.coverImageView.layer.sublayers){
        [subLayer removeFromSuperlayer];
    }
    //
    _imgIndex++;
    if (_imgIndex>3){
        _imgIndex=0;
    }
    UIImage *image;
    image=[UIImage imageNamed:@"手"];
    switch (_imgIndex) {
        case 0:
            image=[UIImage imageNamed:@"手"];
            break;
        case 1:
            image=[UIImage imageNamed:@"手"];
            break;
        case 2:
            image=[UIImage imageNamed:@"手"];
            break;
        default:
            image=[UIImage imageNamed:@"手4"];
            break;
    }
    
    self.coverImageView.image=image;
    CGImageRef cgImage=image.CGImage;
    //
    VNImageRequestHandler *imageRequestHandler=[[VNImageRequestHandler alloc]initWithCGImage:cgImage orientation:kCGImagePropertyOrientationUp options:@{}];
    //
    VNRequest *request;
    if (@available(iOS 14.0, *)) {
        request=[[VNDetectHumanHandPoseRequest alloc]initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
            for(VNObservation *observation in request.results){
                if ([observation isKindOfClass:VNHumanHandPoseObservation.class]){
                    VNHumanHandPoseObservation *pointsObservation=(VNHumanHandPoseObservation *)observation;
                    for (VNRecognizedPointKey pointKey in pointsObservation.availableKeys){
                        NSLog(@"PointKey:%@",pointKey);
                    }
                    for (VNRecognizedPointGroupKey pointGroupKey in pointsObservation.availableGroupKeys){
                        NSLog(@"PointGroupKey:%@",pointGroupKey);
                    }
                    for (VNHumanBodyPoseObservationJointName jointName in pointsObservation.availableJointNames){
                        NSLog(@"JointName:%@",jointName);
                    }
                    for (VNHumanBodyPoseObservationJointsGroupName jointGroupName in pointsObservation.availableJointsGroupNames){
                        NSLog(@"JointName:%@",jointGroupName);
                    }
                    NSDictionary<VNRecognizedPointKey,VNRecognizedPoint *> * pointDict=[pointsObservation recognizedPointsForGroupKey:VNRecognizedPointGroupKeyAll error:nil];
                    NSArray *keys = [pointDict allKeys];
                    NSMutableArray *pointsArg=[NSMutableArray array];
                    for (int i = 0; i < keys.count; i++){
                        VNRecognizedPointKey key = [keys objectAtIndex: i];
                        VNRecognizedPoint * point = [pointDict objectForKey: key];
                        NSLog (@"RecognizedPoint  Key:%@ , Point: { key:%@ , confidence:%f , point:[%f,%f] ,location:[%f,%f] }", key, point.identifier , point.confidence ,point.x,point.y, point.location.x, point.location.y);
                        [pointsArg addObject:[NSValue valueWithCGPoint:point.location]];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self drawAtLayer:self.coverImageView.layer cgImage:cgImage pointsArg:pointsArg];
                    });
                }
            }
        }];
    }
    //3. Perform Requests
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error;
        if ([imageRequestHandler performRequests:@[request] error:&error]){
        }
    });
}

#pragma mark - Function

-(void)drawAtLayer:(CALayer*)layer cgImage:(CGImageRef)cgImage pointsArg:(NSArray*)pointsArg{
    CGFloat imgWidth = CGImageGetWidth(cgImage);
    CGFloat imgHeight = CGImageGetHeight(cgImage);
    CGRect layerBound = layer.bounds;
    CGFloat ratio=1.0f;
    if ((imgWidth/imgHeight)<(layerBound.size.width/layerBound.size.height)){
        ratio=layerBound.size.height/imgHeight;
    }else{
        ratio=layerBound.size.width/imgWidth;
    }
    CGRect shapeLayerBound=CGRectMake(0, 0, imgWidth*ratio, imgHeight*ratio);
    CAShapeLayer *shapeLayer=[CAShapeLayer layer];
    shapeLayer.bounds=shapeLayerBound;
    shapeLayer.position=CGPointMake(layerBound.size.width/2, layerBound.size.height/2);
    UIBezierPath *path=[UIBezierPath bezierPath];
    for(NSValue * pointValue in pointsArg){
        CGPoint normalizedPoint=[pointValue CGPointValue];
        CGPoint imagePoint=VNImagePointForNormalizedPoint(normalizedPoint,shapeLayerBound.size.width,
                                                          shapeLayerBound.size.height);
        CGPoint layerPoint=CGPointMake(imagePoint.x, shapeLayerBound.size.height-imagePoint.y);
        [path moveToPoint:layerPoint];
        [path addArcWithCenter:layerPoint radius:2 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    }
    shapeLayer.path=path.CGPath;
    shapeLayer.strokeColor=UIColor.redColor.CGColor;
    shapeLayer.fillColor=UIColor.clearColor.CGColor;
    shapeLayer.lineWidth=4;
    [layer addSublayer:shapeLayer];
}

@end
