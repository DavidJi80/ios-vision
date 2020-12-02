//
//  ViewController.m
//  ios-vision
//
//  Created by mac on 2020/11/17.
//

#import "ViewController.h"
#import "StillImageVC.h"
#import "SaliencyVC.h"
#import "BodyVC.h"
#import "ContourVC.h"

@interface ViewController ()

@property (strong, nonatomic) UIButton *stillImageBtn;
@property (strong, nonatomic) UIButton *saliencyBtn;
@property (strong, nonatomic) UIButton *bodyBtn;
@property (strong, nonatomic) UIButton *contourBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configBaseUI];
}

#pragma mark - BaseSet

- (void)configBaseUI{
    [self.view addSubview:self.saliencyBtn];
    [self.saliencyBtn makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(100);
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
        make.height.equalTo(40);
    }];
    
    [self.view addSubview:self.stillImageBtn];
    [self.stillImageBtn makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.saliencyBtn.bottom).offset(10);
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
        make.height.equalTo(40);
    }];
    
    [self.view addSubview:self.bodyBtn];
    [self.bodyBtn makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.stillImageBtn.bottom).offset(10);
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
        make.height.equalTo(40);
    }];
    
    [self.view addSubview:self.contourBtn];
    [self.contourBtn makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bodyBtn.bottom).offset(10);
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
        make.height.equalTo(40);
    }];
}

#pragma mark - Lazy

- (UIButton *)stillImageBtn{
    if (!_stillImageBtn) {
        UIButton *button = [[UIButton alloc]init];
        [button setBackgroundImage:nil forState:UIControlStateNormal];
        [button setTitle:@"7. Face and Body Detection" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(stillImageBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor=UIColor.brownColor;
        _stillImageBtn = button;
    }
    return _stillImageBtn;
}

- (UIButton *)saliencyBtn{
    if (!_saliencyBtn) {
        UIButton *button = [[UIButton alloc]init];
        [button setBackgroundImage:nil forState:UIControlStateNormal];
        [button setTitle:@"4. Saliency Analysis" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(aliencyBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor=UIColor.brownColor;
        _saliencyBtn = button;
    }
    return _saliencyBtn;
}

- (UIButton *)bodyBtn{
    if (!_bodyBtn) {
        UIButton *button = [[UIButton alloc]init];
        [button setBackgroundImage:nil forState:UIControlStateNormal];
        [button setTitle:@"8. Body and Hand Pose Detection" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(bodyBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor=UIColor.brownColor;
        _bodyBtn = button;
    }
    return _bodyBtn;
}

- (UIButton *)contourBtn{
    if (!_contourBtn) {
        UIButton *button = [[UIButton alloc]init];
        [button setBackgroundImage:nil forState:UIControlStateNormal];
        [button setTitle:@"10. Contour Detection" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(contourBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor=UIColor.brownColor;
        _contourBtn = button;
    }
    return _contourBtn;
}

#pragma mark - Action

-(void)stillImageBtnAction:(UIButton*)btn{
    StillImageVC *vc=[StillImageVC new];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)aliencyBtnAction:(UIButton*)btn{
    SaliencyVC *vc=[SaliencyVC new];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)bodyBtnAction:(UIButton*)btn{
    BodyVC *vc=[BodyVC new];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)contourBtnAction:(UIButton*)btn{
    ContourVC *vc=[ContourVC new];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
