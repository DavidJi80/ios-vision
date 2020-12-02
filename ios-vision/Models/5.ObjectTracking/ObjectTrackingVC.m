//
//  ObjectTrackingVC.m
//  ios-vision
//
//  Created by mac on 2020/12/2.
//

#import "ObjectTrackingVC.h"
#import <AVFoundation/AVFoundation.h>
#import <Vision/Vision.h>

@interface ObjectTrackingVC ()<AVCaptureVideoDataOutputSampleBufferDelegate>

//Capture
@property (nonatomic, strong) AVCaptureSession              * captureSession;
@property (nonatomic, strong) AVCaptureDevice               * videoDevice;
@property (nonatomic, strong) AVCaptureDevice               * audioDevice;
@property (nonatomic, strong) AVCaptureDeviceInput          * videoDeviceInput;
@property (nonatomic, strong) AVCaptureDeviceInput          * audioDeviceInput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer    * previewLayer;
@property (nonatomic, strong) AVCaptureVideoDataOutput      * videoDataOutput;
//Vision
@property (nonatomic, strong) VNDetectFaceRectanglesRequest * faceRectRequest;
@property (nonatomic, strong) VNSequenceRequestHandler      * sequenceRequestHandler;
@property (nonatomic, strong) VNTrackObjectRequest          * trackObjectRequest;
//UI
@property (nonatomic, assign) CAShapeLayer * canvasLayer;

@end

@implementation ObjectTrackingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configCapture];
    
    [self.view.layer addSublayer:self.canvasLayer];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //设置屏幕常亮
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    [self.captureSession startRunning];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //取消设置屏幕常亮
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    [self.captureSession stopRunning];
    
}

#pragma mark - Capture

-(void)configCapture{
    if (self.videoDeviceInput) {
        if ([self.captureSession canAddInput:self.videoDeviceInput]) {
            [self.captureSession addInput:self.videoDeviceInput];
        }
    }
    if (self.audioDeviceInput) {
        if ([self.captureSession canAddInput:self.audioDeviceInput]) {
            [self.captureSession addInput:self.audioDeviceInput];
        }
    }
    if (self.videoDataOutput){
        if ([self.captureSession canAddOutput:self.videoDataOutput]){
            [self.captureSession addOutput:self.videoDataOutput];
        }
    }
    [self.view.layer addSublayer:self.previewLayer];
    
}
#pragma mark - Lazy init
-(CAShapeLayer *)canvasLayer{
    if (!_canvasLayer) {
        CAShapeLayer * layer = [[CAShapeLayer alloc] init];
        layer.bounds = CGRectMake(0, 0, 300, 534);
        layer.position=self.view.layer.position;
        layer.strokeColor=UIColor.greenColor.CGColor;
        layer.fillColor=UIColor.clearColor.CGColor;
        _canvasLayer = layer;
    }
    return _canvasLayer;
}


#pragma mark -- Lazy init - Capture

- (AVCaptureSession *)captureSession{
    if (!_captureSession) {
        AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
        captureSession.sessionPreset=AVCaptureSessionPreset1920x1080;
        _captureSession = captureSession;
    }
    return _captureSession;
}

-(AVCaptureDevice *)videoDevice{
    if (!_videoDevice) {
        AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
        _videoDevice = captureDevice;
    }
    return _videoDevice;
}

-(AVCaptureDevice *)audioDevice{
    if (!_audioDevice) {
        AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        _audioDevice = captureDevice;
    }
    return _audioDevice;
}

-(AVCaptureDeviceInput *)videoDeviceInput{
    if (!_videoDeviceInput) {
        AVCaptureDeviceInput *deviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.videoDevice error:nil];
        _videoDeviceInput = deviceInput;
    }
    return _videoDeviceInput;
}

-(AVCaptureDeviceInput *)audioDeviceInput{
    if (!_audioDeviceInput) {
        AVCaptureDeviceInput *deviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.audioDevice error:nil];
        _audioDeviceInput = deviceInput;
    }
    return _audioDeviceInput;
}

-(AVCaptureVideoPreviewLayer *)previewLayer{
    if (!_previewLayer) {
        AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
        previewLayer.bounds = CGRectMake(0, 0, 300, 534);
        previewLayer.position=self.view.layer.position;
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        _previewLayer = previewLayer;
    }
    return _previewLayer;
}

-(AVCaptureVideoDataOutput *)videoDataOutput{
    if (!_videoDataOutput) {
        AVCaptureVideoDataOutput *videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        dispatch_queue_t queue=dispatch_queue_create("net.tongark.camera", DISPATCH_QUEUE_SERIAL);
        [videoDataOutput setSampleBufferDelegate:self queue:queue];
        _videoDataOutput = videoDataOutput;
    }
    return _videoDataOutput;
}

#pragma mark -- Lazy init - Vision

-(VNDetectFaceRectanglesRequest *)faceRectRequest{
    if (!_faceRectRequest) {
        VNDetectFaceRectanglesRequest *request = [[VNDetectFaceRectanglesRequest alloc] init];
        _faceRectRequest = request;
    }
    return _faceRectRequest;
}

-(VNSequenceRequestHandler *)sequenceRequestHandler{
    if (!_sequenceRequestHandler) {
        VNSequenceRequestHandler *handler = [[VNSequenceRequestHandler alloc] init];
        _sequenceRequestHandler = handler;
    }
    return _sequenceRequestHandler;
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    if (output != self.videoDataOutput) return;
    CVPixelBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    //没有跟踪对象先识别人脸，识别成功后存储在trackObjectRequest
    if (!self.trackObjectRequest){
        VNImageRequestHandler *imageRequestHandler=[[VNImageRequestHandler alloc]initWithCVPixelBuffer:imageBuffer orientation:kCGImagePropertyOrientationUp options:@{}];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSError *error;
            [imageRequestHandler performRequests:@[self.faceRectRequest] error:&error];
            if (error){
                NSLog(@"%@",error.localizedDescription);
                return;
            }
                
            // faceRectRequest
            for(VNObservation *observation in self.faceRectRequest.results){
                if ([observation isKindOfClass:VNFaceObservation.class]){
                    VNFaceObservation *faceObserv=(VNFaceObservation *)observation;
                    self.trackObjectRequest=[[VNTrackObjectRequest alloc]initWithDetectedObjectObservation:faceObserv];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self drawWithFaceBoundingBox:faceObserv.boundingBox];
                    });
                    
                }
            }
            
        });
        
        return;
        
    }
    
    // 跟踪识别
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.sequenceRequestHandler performRequests:@[self.trackObjectRequest] onCVPixelBuffer:imageBuffer orientation:kCGImagePropertyOrientationUp error:nil];
        if (self.trackObjectRequest.results.count<1)return;
        VNDetectedObjectObservation *trackObjectObservation=self.trackObjectRequest.results[0];
        if (!self.trackObjectRequest.lastFrame){
            if (trackObjectObservation.confidence>0.3){
                self.trackObjectRequest.inputObservation=trackObjectObservation;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self drawWithFaceBoundingBox:trackObjectObservation.boundingBox];
        });
    });
}

#pragma mark - Function

-(void)drawWithFaceBoundingBox:(CGRect)faceBoundingBox{
    
    CGRect imgFaceRect = VNImageRectForNormalizedRect(faceBoundingBox,534,300);
    CGRect layerFaceRect = [self layerRectFromImageRect:imgFaceRect];
    UIBezierPath *path=[UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(layerFaceRect.origin.x, layerFaceRect.origin.y)];
    [path addLineToPoint:CGPointMake(layerFaceRect.origin.x+layerFaceRect.size.width, layerFaceRect.origin.y)];
    [path addLineToPoint:CGPointMake(layerFaceRect.origin.x+layerFaceRect.size.width, layerFaceRect.origin.y+layerFaceRect.size.height)];
    [path addLineToPoint:CGPointMake(layerFaceRect.origin.x, layerFaceRect.origin.y+layerFaceRect.size.height)];
    [path addLineToPoint:CGPointMake(layerFaceRect.origin.x, layerFaceRect.origin.y)];
    

    self.canvasLayer.path=path.CGPath;
    
}

-(CGRect)layerRectFromImageRect:(CGRect)imageRect{
    CGFloat width=imageRect.size.height;
    CGFloat height=imageRect.size.width;
    CGFloat x=300-height-imageRect.origin.y;
    CGFloat y=imageRect.origin.x;
    return CGRectMake(x,y,width,height);
}


@end
