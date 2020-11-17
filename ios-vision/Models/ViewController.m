//
//  ViewController.m
//  ios-vision
//
//  Created by mac on 2020/11/17.
//

#import "ViewController.h"

@interface ViewController ()

@property (strong, nonatomic) UIButton *stillImageBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configBaseUI];
}

#pragma mark - BaseSet
- (void)configBaseUI{
    [self.view addSubview:self.stillImageBtn];
    [self.stillImageBtn makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(100);
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
        [button setTitle:@"Still Image Analysis" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(stillImageBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor=UIColor.brownColor;
        _stillImageBtn = button;
    }
    return _stillImageBtn;
}

-(void)stillImageBtnAction:(UIButton*)btn{
    
}


@end
