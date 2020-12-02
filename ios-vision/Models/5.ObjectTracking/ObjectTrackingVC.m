//
//  ObjectTrackingVC.m
//  ios-vision
//
//  Created by mac on 2020/12/2.
//

#import "ObjectTrackingVC.h"
#import <AVFoundation/AVFoundation.h>

@interface ObjectTrackingVC ()

//Capture
@property (nonatomic, strong) AVCaptureSession * captureSession;
@property (nonatomic, strong) AVCaptureDevice *videoDevice;
@property (nonatomic, strong) AVCaptureDevice *audioDevice;
@property (nonatomic, strong) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic, strong) AVCaptureDeviceInput *audioDeviceInput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@end

@implementation ObjectTrackingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configCapture];
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
    [self.view.layer addSublayer:self.previewLayer];
    
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
        AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
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
        previewLayer.frame = self.view.layer.bounds;
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _previewLayer = previewLayer;
    }
    return _previewLayer;
}

@end
