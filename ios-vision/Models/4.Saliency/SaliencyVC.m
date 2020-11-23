//
//  SaliencyVC.m
//  ios-vision
//
//  Created by mac on 2020/11/21.
//

#import "SaliencyVC.h"
#import <Vision/Vision.h>

@interface SaliencyVC (){
    int _imgIndex;
}

@property (strong,nonatomic) UIButton *baseAttentionBtn;
@property (strong,nonatomic) UIButton *baseObjectBtn;
@property (nonatomic,strong) UIImageView *coverImageView;
@property (nonatomic,strong) UIImageView *outputImageView;

@end

@implementation SaliencyVC

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
    
    [self.view addSubview:self.outputImageView];
    [self.outputImageView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(100);
        make.left.equalTo(self.view).offset(10);
        make.width.equalTo(100);
        make.height.equalTo(100);
    }];
    
    [self.view addSubview:self.baseAttentionBtn];
    [self.baseAttentionBtn makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view.centerX).offset(-5);
        make.bottom.equalTo(self.view).offset(-80);
        make.height.equalTo(40);
    }];
    
    [self.view addSubview:self.baseObjectBtn];
    [self.baseObjectBtn makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.baseAttentionBtn.right).offset(10);
        make.right.equalTo(self.view).offset(-10);
        make.bottom.equalTo(self.view).offset(-80);
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

- (UIImageView *)outputImageView{
    if (!_outputImageView) {
        UIImageView *imageView=[UIImageView new];
//        imageView.backgroundColor=UIColor.greenColor;
        imageView.contentMode=UIViewContentModeScaleAspectFit;
        imageView.clipsToBounds=YES;
        _outputImageView=imageView;
    }
    return _outputImageView;
}

- (UIButton *)baseAttentionBtn{
    if (!_baseAttentionBtn) {
        UIButton *button = [[UIButton alloc]init];
        [button setBackgroundImage:nil forState:UIControlStateNormal];
        [button setTitle:@"Attention" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(stillImageBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor=UIColor.brownColor;
        _baseAttentionBtn = button;
    }
    return _baseAttentionBtn;
}

- (UIButton *)baseObjectBtn{
    if (!_baseObjectBtn) {
        UIButton *button = [[UIButton alloc]init];
        [button setBackgroundImage:nil forState:UIControlStateNormal];
        [button setTitle:@"Objectness" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(stillImageBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor=UIColor.brownColor;
        _baseObjectBtn = button;
    }
    return _baseObjectBtn;
}

#pragma mark - Action

-(void)stillImageBtnAction:(UIButton*)btn{
    for(CALayer *subLayer in self.coverImageView.layer.sublayers){
        [subLayer removeFromSuperlayer];
    }
    //
    _imgIndex++;
    if (_imgIndex>3){
        _imgIndex=0;
    }
    UIImage *image;
    switch (_imgIndex) {
        case 0:
            image=[UIImage imageNamed:@"头像"];
            break;
        case 1:
            image=[UIImage imageNamed:@"头像2"];
            break;
        case 2:
            image=[UIImage imageNamed:@"人像"];
            break;
        default:
            image=[UIImage imageNamed:@"人像2"];
            break;
    }
    CGImageRef cgImage=image.CGImage;
    self.coverImageView.image=image;
    //
    VNRequest *request;
    if (btn==self.baseAttentionBtn){
        request = [[VNGenerateAttentionBasedSaliencyImageRequest alloc] init];
    }else{
        request = [[VNGenerateObjectnessBasedSaliencyImageRequest alloc] init];
    }
    //
    VNImageRequestHandler *imageRequestHandler=[[VNImageRequestHandler alloc]initWithCGImage:cgImage orientation:kCGImagePropertyOrientationUp options:@{}];
    
    //3. Perform Requests
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error;
        if ([imageRequestHandler performRequests:@[request] error:&error]){
            for(VNObservation *observation in request.results){
                if ([observation isKindOfClass:VNSaliencyImageObservation.class]){
                    VNSaliencyImageObservation *saliencyObservation=(VNSaliencyImageObservation *)observation;
//                    NSLog(@"%@,%@",saliencyObservation.featureName);
                    NSArray<VNRectangleObservation *> *salientObjects=saliencyObservation.salientObjects;
                    NSMutableArray * rectsArg = [NSMutableArray array];
                    for(VNRectangleObservation * rectangleObs in salientObjects){
                        NSMutableArray * oneRectArg = [NSMutableArray array];
                        [oneRectArg addObject:[NSValue valueWithCGPoint:rectangleObs.bottomLeft]];
                        [oneRectArg addObject:[NSValue valueWithCGPoint:rectangleObs.bottomRight]];
                        [oneRectArg addObject:[NSValue valueWithCGPoint:rectangleObs.topRight]];
                        [oneRectArg addObject:[NSValue valueWithCGPoint:rectangleObs.topLeft]];
                        [rectsArg addObject:oneRectArg];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf drawAtLayer:self.coverImageView.layer cgImage:cgImage rectsArg:rectsArg];
                        UIImage *image=[self convertToImageFromCVImageBufferRef:saliencyObservation.pixelBuffer];
                        [weakSelf.outputImageView setImage:image];
                    });
                    
                }
            }
        }
    });
}

#pragma mark - Function

-(void)drawAtLayer:(CALayer*)layer cgImage:(CGImageRef)cgImage rectsArg:(NSArray*)rectsArg{
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
    for(NSArray * pointsArg in rectsArg){
        CGPoint point0=CGPointZero;
        for(int i=0;i<pointsArg.count;i++){
            NSValue * pointValue = pointsArg[i];
            CGPoint normalizedPoint=[pointValue CGPointValue];
            CGPoint imagePoint=VNImagePointForNormalizedPoint(normalizedPoint,shapeLayerBound.size.width,
                                                              shapeLayerBound.size.height);
            CGPoint layerPoint=CGPointMake(imagePoint.x, shapeLayerBound.size.height-imagePoint.y);
            if (i==0){
                point0=layerPoint;
                [path moveToPoint:layerPoint];
            }else{
                [path addLineToPoint:layerPoint];
            }
        }
        [path addLineToPoint:point0];
    }
    
    shapeLayer.path=path.CGPath;
    shapeLayer.strokeColor=UIColor.greenColor.CGColor;
    shapeLayer.fillColor=UIColor.clearColor.CGColor;
    [layer addSublayer:shapeLayer];
    
}

-(UIImage *) convertToImageFromCVImageBufferRef:( CVImageBufferRef)pixelBuffer{
    CVImageBufferRef imageBuffer =pixelBuffer;
    /*Lock the image buffer*/
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    /*Get information about the image*/
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);

    /*We unlock the  image buffer*/
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);

    /*Create a CGImageRef from the CVImageBufferRef*/
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef newImage = CGBitmapContextCreateImage(newContext);

    /*We release some components*/
    CGContextRelease(newContext);
    CGColorSpaceRelease(colorSpace);
    
    UIImage *image=[UIImage imageWithCGImage:newImage];
    
    return image;
}


@end
