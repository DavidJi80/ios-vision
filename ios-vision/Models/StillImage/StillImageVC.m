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
}

#pragma mark - Lazy init

- (UIImageView *)coverImageView{
    if (!_coverImageView) {
        UIImageView *imageView=[UIImageView new];
        imageView.backgroundColor=UIColor.lightGrayColor;
        imageView.contentMode=UIViewContentModeScaleAspectFit;
        imageView.clipsToBounds=YES;
        imageView.image=[UIImage imageNamed:@"头像"];
        _coverImageView=imageView;
    }
    return _coverImageView;
}

- (UIButton *)stillImageBtn{
    if (!_stillImageBtn) {
        UIButton *button = [[UIButton alloc]init];
        [button setBackgroundImage:nil forState:UIControlStateNormal];
        [button setTitle:@"Detecting Objects in Still Images" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(stillImageBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor=UIColor.brownColor;
        _stillImageBtn = button;
    }
    return _stillImageBtn;
}

#pragma mark - Action

-(void)stillImageBtnAction:(UIButton*)btn{
    CGImageRef cgImage=[UIImage imageNamed:@"头像"].CGImage;
    
    
    VNImageRequestHandler *imageRequestHandler=[[VNImageRequestHandler alloc]initWithCGImage:cgImage orientation:kCGImagePropertyOrientationUp options:@{}];
    
    VNDetectFaceRectanglesRequest *faceRectRequest=[[VNDetectFaceRectanglesRequest alloc]initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error;
        if ([imageRequestHandler performRequests:@[faceRectRequest] error:&error]){
            for(VNObservation *observation in faceRectRequest.results){
                if ([observation isKindOfClass:VNFaceObservation.class]){
                    VNFaceObservation *faceObserv=(VNFaceObservation *)observation;
                    NSLog(@"roll:%@,yaw:%@,faceCaptureQuality:%@",faceObserv.roll,faceObserv.yaw,faceObserv.faceCaptureQuality);
                    NSLog(@"BoundingBox:[%f,%f,%f,%f]",
                          faceObserv.boundingBox.origin.x,
                          faceObserv.boundingBox.origin.y,
                          faceObserv.boundingBox.size.width,
                          faceObserv.boundingBox.size.height);
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self drawFaceWithBoundingBox:faceObserv.boundingBox cgImage:cgImage];
                    });
                    
                    
                }
            }
        }else{
            NSLog(@"%@",error.localizedDescription);
        }
    });
}

#pragma mark - Function

-(void)drawFaceWithBoundingBox:(CGRect)boundingBox cgImage:(CGImageRef)cgImage{
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
    [self.coverImageView.layer addSublayer:shapeLayer];
}


@end
