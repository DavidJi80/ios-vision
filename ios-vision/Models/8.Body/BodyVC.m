//
//  BodyVC.m
//  ios-vision
//
//  Created by mac on 2020/11/22.
//

#import "BodyVC.h"
#import <Vision/Vision.h>

@interface BodyVC ()

@property (nonatomic,strong) UIImageView *coverImageView;
@property (strong,nonatomic) UIButton *bodyBtn;

@end

@implementation BodyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configBaseUI];
//    _imgIndex=0;
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

#pragma mark - Action

-(void)bodyBtnAction:(UIButton*)btn{
    UIImage *image;
    image=[UIImage imageNamed:@"人像"];
    self.coverImageView.image=image;
    CGImageRef cgImage=image.CGImage;
    //
    VNImageRequestHandler *imageRequestHandler=[[VNImageRequestHandler alloc]initWithCGImage:cgImage orientation:kCGImagePropertyOrientationUp options:@{}];
    //
    VNRequest *request;
    if (@available(iOS 14.0, *)) {
        request=[[VNDetectHumanBodyPoseRequest alloc]initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
            for(VNObservation *observation in request.results){
                if ([observation isKindOfClass:VNRecognizedPointsObservation.class]){
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
