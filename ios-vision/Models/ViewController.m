//
//  ViewController.m
//  ios-vision
//
//  Created by mac on 2020/11/17.
//

#import "ViewController.h"
#import "StillImageVC.h"
#import "SaliencyVC.h"

@interface ViewController ()

@property (strong, nonatomic) UIButton *stillImageBtn;
@property (strong, nonatomic) UIButton *saliencyBtn;

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
        [button setTitle:@"4. Cropping Images Using Saliency" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(aliencyBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor=UIColor.brownColor;
        _saliencyBtn = button;
    }
    return _saliencyBtn;
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


@end
