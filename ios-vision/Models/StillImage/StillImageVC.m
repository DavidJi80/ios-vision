//
//  StillImageVC.m
//  ios-vision
//
//  Created by mac on 2020/11/18.
//

#import "StillImageVC.h"
#import <Vision/Vision.h>

@interface StillImageVC ()

@property (nonatomic,strong) UIImageView *coverImageView;   //封面
@property (strong,nonatomic) UIButton *stillImageBtn;
@property (strong,nonatomic) UIButton *detectHumanBtn;

@end

@implementation StillImageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configBaseUI];
}

#pragma mark - BaseSet

- (void)configBaseUI{
    [self.view addSubview:self.coverImageView];
    [self.coverImageView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(100);
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
        make.bottom.equalTo(self.view).offset(-200);
    }];
    
    [self.view addSubview:self.stillImageBtn];
    [self.stillImageBtn makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.coverImageView.bottom).offset(10);
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
        make.height.equalTo(40);
    }];
    
    [self.view addSubview:self.detectHumanBtn];
    [self.detectHumanBtn makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.stillImageBtn.bottom).offset(10);
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
//        imageView.image=[UIImage imageNamed:@"头像"];
        _coverImageView=imageView;
    }
    return _coverImageView;
}

- (UIButton *)stillImageBtn{
    if (!_stillImageBtn) {
        UIButton *button = [[UIButton alloc]init];
        [button setBackgroundImage:nil forState:UIControlStateNormal];
        [button setTitle:@"Detecting Face & Landmark in Still Images" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(stillImageBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor=UIColor.brownColor;
        _stillImageBtn = button;
    }
    return _stillImageBtn;
}

- (UIButton *)detectHumanBtn{
    if (!_detectHumanBtn) {
        UIButton *button = [[UIButton alloc]init];
        [button setBackgroundImage:nil forState:UIControlStateNormal];
        [button setTitle:@"Detecting Human in Still Images" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(detectHumanBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor=UIColor.orangeColor;
        _detectHumanBtn = button;
    }
    return _detectHumanBtn;
}

#pragma mark - Action

-(void)stillImageBtnAction:(UIButton*)btn{
    //1. VNImageRequestHandler
    UIImage *image=[UIImage imageNamed:@"头像"];
    self.coverImageView.image=image;
    CGImageRef cgImage=image.CGImage;
    VNImageRequestHandler *imageRequestHandler=[[VNImageRequestHandler alloc]initWithCGImage:cgImage orientation:kCGImagePropertyOrientationUp options:@{}];
    
    //2. VNRequest
    //2.1. VNDetectFaceRectanglesRequest
    VNDetectFaceRectanglesRequest *faceRectRequest=[[VNDetectFaceRectanglesRequest alloc]initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
    }];
    
    //2.2. VNDetectFaceLandmarksRequest
    VNDetectFaceLandmarksRequest *faceLandmarkRequest=[[VNDetectFaceLandmarksRequest alloc]initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
    }];
    
    //2.3. VNDetectFaceCaptureQualityRequest
    VNDetectFaceCaptureQualityRequest *faceCaptureQualityRequest=[[VNDetectFaceCaptureQualityRequest alloc]initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
        for(VNObservation *observation in request.results){
            if ([observation isKindOfClass:VNFaceObservation.class]){
                VNFaceObservation *faceObserv=(VNFaceObservation *)observation;
                NSLog(@"faceCaptureQuality:%@",faceObserv.faceCaptureQuality);
            }
        }
    }];
    
    //3. Perform Requests
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error;
        if ([imageRequestHandler performRequests:@[faceRectRequest,faceLandmarkRequest,faceCaptureQualityRequest] error:&error]){
            // faceRectRequest
            CGRect faceBoundingBox=VNNormalizedIdentityRect;
            for(VNObservation *observation in faceRectRequest.results){
                if ([observation isKindOfClass:VNFaceObservation.class]){
                    VNFaceObservation *faceObserv=(VNFaceObservation *)observation;
                    faceBoundingBox=faceObserv.boundingBox;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self drawRectWithBoundingBox:faceBoundingBox cgImage:cgImage];
                    });
                }
            }
            // faceLandmarkRequest
            CGFloat imgWidth = CGImageGetWidth(cgImage);
            CGFloat imgHeight = CGImageGetHeight(cgImage);
            CGRect imgBoundingBox = VNImageRectForNormalizedRect(faceBoundingBox,imgWidth,imgHeight);
            
            for(VNObservation *observation in faceLandmarkRequest.results){
                if ([observation isKindOfClass:VNFaceObservation.class]){
                    VNFaceObservation *faceObserv=(VNFaceObservation *)observation;
                    VNFaceLandmarks2D *landmarks=faceObserv.landmarks;
                    NSLog(@"confidence:%f",landmarks.confidence);
                    VNFaceLandmarkRegion2D *faceContour=landmarks.faceContour;
                    NSLog(@"faceContour count:%lu",(unsigned long)faceContour.pointCount);
                    for (NSUInteger i=0;i<faceContour.pointCount;i++){
                        CGPoint point=faceContour.normalizedPoints[i];
                        NSLog(@"Point%d:[%f,%f]",(int)i,point.x,point.y);
                        vector_float2 faceLandmarkPoint={point.x,point.y};
                        CGPoint imagePoint=VNImagePointForFaceLandmarkPoint(faceLandmarkPoint, faceBoundingBox, imgBoundingBox.size.width, imgBoundingBox.size.height);
                        NSLog(@"Point%d:[%f,%f]",(int)i,imagePoint.x,imagePoint.y);
                    }
                }
            }
        }else{
            NSLog(@"%@",error.localizedDescription);
        }
    });
}

-(void)detectHumanBtnAction:(UIButton*)btn{
    //1. VNImageRequestHandler
    UIImage *image=[UIImage imageNamed:@"人像"];
    self.coverImageView.image=image;
    CGImageRef cgImage=image.CGImage;
    VNImageRequestHandler *imageRequestHandler=[[VNImageRequestHandler alloc]initWithCGImage:cgImage orientation:kCGImagePropertyOrientationUp options:@{}];
    
    //2. VNDetectHumanRectanglesRequest
    VNDetectHumanRectanglesRequest *humanRectanglesRequest=[[VNDetectHumanRectanglesRequest alloc]initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
        for(VNObservation *observation in request.results){
            if ([observation isKindOfClass:VNDetectedObjectObservation.class]){
                VNDetectedObjectObservation *faceObserv=(VNDetectedObjectObservation *)observation;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self drawRectWithBoundingBox:faceObserv.boundingBox cgImage:cgImage];
                });
            }
        }
    }];
    
    //3. Perform Requests
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error;
        if ([imageRequestHandler performRequests:@[humanRectanglesRequest] error:&error]){
            
        }else{
            NSLog(@"%@",error.localizedDescription);
        }
    });
    
}

#pragma mark - Function

-(void)drawRectWithBoundingBox:(CGRect)boundingBox cgImage:(CGImageRef)cgImage{
    CGFloat imgWidth = CGImageGetWidth(cgImage);
    CGFloat imgHeight = CGImageGetHeight(cgImage);
    CGRect imgBoundingBox = VNImageRectForNormalizedRect(boundingBox,imgWidth,imgHeight);
    CGRect layerBound = self.coverImageView.layer.bounds;
    CGFloat ratio=1.0f;
    if ((imgWidth/imgHeight)<(layerBound.size.width/layerBound.size.height)){
        ratio=layerBound.size.height/imgHeight;
        
    }else{
        ratio=layerBound.size.width/imgWidth;
    }
    CAShapeLayer *shapeLayer=[CAShapeLayer layer];
    shapeLayer.bounds=CGRectMake(0, 0, imgWidth*ratio, imgHeight*ratio);
    shapeLayer.position=CGPointMake(layerBound.size.width/2, layerBound.size.height/2);
    UIBezierPath *facePath=[UIBezierPath bezierPath];
    [facePath moveToPoint:CGPointMake(imgBoundingBox.origin.x*ratio, (imgHeight-imgBoundingBox.origin.y)*ratio)];
    [facePath addLineToPoint:CGPointMake((imgBoundingBox.origin.x+imgBoundingBox.size.width)*ratio, (imgHeight-imgBoundingBox.origin.y)*ratio)];
    [facePath addLineToPoint:CGPointMake((imgBoundingBox.origin.x+imgBoundingBox.size.width)*ratio, (imgHeight-imgBoundingBox.origin.y-imgBoundingBox.size.height)*ratio)];
    [facePath addLineToPoint:CGPointMake(imgBoundingBox.origin.x*ratio, (imgHeight-imgBoundingBox.origin.y-imgBoundingBox.size.height)*ratio)];
    [facePath closePath];
    shapeLayer.path=facePath.CGPath;
    shapeLayer.strokeColor=UIColor.greenColor.CGColor;
    shapeLayer.fillColor=UIColor.clearColor.CGColor;
    
    for(CALayer *subLayer in self.coverImageView.layer.sublayers){
        [subLayer removeFromSuperlayer];
    }
    [self.coverImageView.layer addSublayer:shapeLayer];
}


@end
