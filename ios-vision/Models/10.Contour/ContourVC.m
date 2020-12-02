//
//  ContourVC.m
//  ios-vision
//
//  Created by mac on 2020/11/30.
//

#import "ContourVC.h"
#import <Vision/Vision.h>

@interface ContourVC (){
    int _imgIndex;
}

@property (nonatomic,strong) UIImageView    *coverImageView;
@property (strong,nonatomic) UIButton       *contourBtn;

@end

@implementation ContourVC

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
    
    [self.view addSubview:self.contourBtn];
    [self.contourBtn makeConstraints:^(MASConstraintMaker *make) {
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
        _coverImageView=imageView;
    }
    return _coverImageView;
}

- (UIButton *)contourBtn{
    if (!_contourBtn) {
        UIButton *button = [[UIButton alloc]init];
        [button setTitle:@"Detecting Contours in Images" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(contourBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor=UIColor.brownColor;
        _contourBtn = button;
    }
    return _contourBtn;
}

#pragma mark - Action

-(void)contourBtnAction:(UIButton*)btn{
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
        request=[[VNDetectContoursRequest alloc]initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
            for(VNObservation *observation in request.results){
                if ([observation isKindOfClass:VNContoursObservation.class]){
                    VNContoursObservation *contoursObservation=(VNContoursObservation *)observation;
                    NSLog(@"%ld,%ld,%ld",(long)contoursObservation.contourCount,(long)contoursObservation.topLevelContours,contoursObservation.topLevelContours.count);
                    for(VNContour *contour in contoursObservation.topLevelContours){
                        
                    }
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

@end
