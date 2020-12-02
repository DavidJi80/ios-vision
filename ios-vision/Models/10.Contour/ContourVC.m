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
                    
                    NSMutableArray *groupsArg=[NSMutableArray array];
                    
                    for(VNContour *contour in contoursObservation.topLevelContours){
                        NSLog(@"轮廓的高宽比:%f",contour.aspectRatio);
                        NSLog(@"索引路径:%@",contour.indexPath);
                        NSLog(@"轮廓线点的数量:%ld",contour.pointCount);
                        NSLog(@"子轮廓的数量:%ld",contour.childContourCount);
                        VNContour *simpleContour=[contour polygonApproximationWithEpsilon:0.01 error:nil];
                        NSLog(@"轮廓线点的数量:%ld",simpleContour.pointCount);
                        NSMutableArray *pointsArg=[NSMutableArray array];
                        for(int i=0;i<simpleContour.pointCount;i++){
                            simd_float2 simd_point=simpleContour.normalizedPoints[i];
                            NSLog(@"%f,%f",simd_point[0],simd_point[1]);
                            [pointsArg addObject:[NSValue valueWithCGPoint:CGPointMake(simd_point[0], simd_point[1])]];
                        }
                        [groupsArg addObject:pointsArg];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self drawAtLayer:self.coverImageView.layer cgImage:cgImage groupsArg:groupsArg];
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

-(void)drawAtLayer:(CALayer*)layer cgImage:(CGImageRef)cgImage groupsArg:(NSArray*)groupsArg{
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

    
    for(NSArray* pointsArg in groupsArg){
        for(int i=0;i<pointsArg.count;i++){
            NSValue * pointValue = pointsArg[i];
            CGPoint normalizedPoint=[pointValue CGPointValue];
            CGPoint imagePoint=VNImagePointForNormalizedPoint(normalizedPoint,shapeLayerBound.size.width,
                                                              shapeLayerBound.size.height);
            CGPoint layerPoint=CGPointMake(imagePoint.x, shapeLayerBound.size.height-imagePoint.y);
            if (i==0){
                [path moveToPoint:layerPoint];
            }else{
                [path addLineToPoint:layerPoint];
            }
        }
    }
    
    shapeLayer.path=path.CGPath;
    shapeLayer.strokeColor=UIColor.redColor.CGColor;
    shapeLayer.fillColor=UIColor.clearColor.CGColor;
    shapeLayer.lineWidth=1;
    [layer addSublayer:shapeLayer];
}


@end
