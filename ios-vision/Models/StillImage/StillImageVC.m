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
                }
            }
            NSMutableArray<NSArray*>* landmarksArg=[NSMutableArray array];
            for(VNObservation *observation in faceLandmarkRequest.results){
                if ([observation isKindOfClass:VNFaceObservation.class]){
                    VNFaceObservation *faceObserv=(VNFaceObservation *)observation;
                    VNFaceLandmarks2D *landmarks=faceObserv.landmarks;
                    NSLog(@"confidence:%f",landmarks.confidence);
                    
                    VNFaceLandmarkRegion2D *faceContour=landmarks.faceContour;
                    VNFaceLandmarkRegion2D *leftEye=landmarks.leftEye;
                    VNFaceLandmarkRegion2D *rightEye=landmarks.rightEye;
                    VNFaceLandmarkRegion2D *leftEyebrow=landmarks.leftEyebrow;
                    VNFaceLandmarkRegion2D *rightEyebrow=landmarks.rightEyebrow;
                    VNFaceLandmarkRegion2D *nose=landmarks.nose;
                    VNFaceLandmarkRegion2D *noseCrest=landmarks.noseCrest;
                    VNFaceLandmarkRegion2D *medianLine=landmarks.medianLine;
                    VNFaceLandmarkRegion2D *outerLips=landmarks.outerLips;
                    VNFaceLandmarkRegion2D *innerLips=landmarks.innerLips;
                    VNFaceLandmarkRegion2D *leftPupil=landmarks.leftPupil;
                    VNFaceLandmarkRegion2D *rightPupil=landmarks.rightPupil;
                    
                    NSMutableArray *landmarkRegionArg=[NSMutableArray array];
                    [landmarkRegionArg addObject:faceContour];
                    [landmarkRegionArg addObject:leftEye];
                    [landmarkRegionArg addObject:rightEye];
                    [landmarkRegionArg addObject:leftEyebrow];
                    [landmarkRegionArg addObject:rightEyebrow];
                    [landmarkRegionArg addObject:nose];
                    [landmarkRegionArg addObject:noseCrest];
                    [landmarkRegionArg addObject:medianLine];
                    [landmarkRegionArg addObject:outerLips];
                    [landmarkRegionArg addObject:innerLips];
                    [landmarkRegionArg addObject:leftPupil];
                    [landmarkRegionArg addObject:rightPupil];
                    
                    for(VNFaceLandmarkRegion2D *landmarkRegion in landmarkRegionArg){
                        NSMutableArray<NSValue*> *landmarkPointArg=[NSMutableArray array];
                        for (NSUInteger i=0;i<landmarkRegion.pointCount;i++){
                            CGPoint point=landmarkRegion.normalizedPoints[i];
                            [landmarkPointArg addObject:[NSValue valueWithCGPoint:point]];
                        }
                        [landmarksArg addObject:landmarkPointArg];
                    }

                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self drawAtLayer:self.coverImageView.layer cgImage:cgImage faceBoundingBox:faceBoundingBox landmarksArg:landmarksArg];
            });
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

-(void)drawAtLayer:(CALayer*)layer cgImage:(CGImageRef)cgImage faceBoundingBox:(CGRect)faceBoundingBox landmarksArg:(NSArray*)landmarksArg{
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
    
    CGRect imgFaceRect = VNImageRectForNormalizedRect(faceBoundingBox,shapeLayerBound.size.width,shapeLayerBound.size.height);
    CGRect layerFaceRect = [self layerRectFromImageRect:imgFaceRect layerHeight:shapeLayerBound.size.height];
    UIBezierPath *path=[UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(layerFaceRect.origin.x, layerFaceRect.origin.y)];
    [path addLineToPoint:CGPointMake(layerFaceRect.origin.x+layerFaceRect.size.width, layerFaceRect.origin.y)];
    [path addLineToPoint:CGPointMake(layerFaceRect.origin.x+layerFaceRect.size.width, layerFaceRect.origin.y+layerFaceRect.size.height)];
    [path addLineToPoint:CGPointMake(layerFaceRect.origin.x, layerFaceRect.origin.y+layerFaceRect.size.height)];
    [path addLineToPoint:CGPointMake(layerFaceRect.origin.x, layerFaceRect.origin.y)];
    
    for(NSArray * pointsArg in landmarksArg){
        for(int i=0;i<pointsArg.count;i++){
            NSValue * pointValue = pointsArg[i];
            CGPoint normalizedPoint=[pointValue CGPointValue];
            vector_float2 pointVector={normalizedPoint.x,normalizedPoint.y};
            CGPoint imageLandmarkPoint=VNImagePointForFaceLandmarkPoint(pointVector, faceBoundingBox, shapeLayerBound.size.width, shapeLayerBound.size.height);
            CGPoint layerLMPoint=CGPointMake(imageLandmarkPoint.x, shapeLayerBound.size.height-imageLandmarkPoint.y);
            if (i==0){
                [path moveToPoint:layerLMPoint];
            }else{
                [path addLineToPoint:layerLMPoint];
            }
        }
    }
    
    shapeLayer.path=path.CGPath;
    shapeLayer.strokeColor=UIColor.greenColor.CGColor;
    shapeLayer.fillColor=UIColor.clearColor.CGColor;
    [layer addSublayer:shapeLayer];
}

-(CGRect)layerRectFromImageRect:(CGRect)imageRect layerHeight:(CGFloat)layerHeight{
    return CGRectMake(imageRect.origin.x,(layerHeight-imageRect.origin.y-imageRect.size.height),imageRect.size.width,imageRect.size.height);
}

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
