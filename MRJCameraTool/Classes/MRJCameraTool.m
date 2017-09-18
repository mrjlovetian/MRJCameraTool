//
//  MRJCameraTool.m
//  Pods
//
//  Created by Mr on 2017/9/18.
//
//

#import "MRJCameraTool.h"
#import "TZImagePickerController.h"
#import "SKFCamera.h"
#import "KKActionSheet.h"

///返回图片的最大分辨率宽度
#define  NEWPIC_WIDTH                         640.0

@interface MRJCameraTool ()<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TZImagePickerControllerDelegate, KKActionSheetDelegate>
@property (nonatomic, strong) NSMutableArray *selectImage;
@end

@implementation MRJCameraTool

+(id)cameraToolDefault{
    /*****
     占用一个像素的主屏幕位置
     确保委托方法的顺利执行
     */
    CameraTool *camTool = [[CameraTool alloc]initWithFrame:CGRectMake(0, 0, 1, 1)];
    camTool.backgroundColor = [UIColor clearColor];
    camTool.width = NEWPIC_WIDTH;
    camTool.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    return camTool;
}

+ (void)cameraAtView:(UIViewController *)myVC isEdit:(BOOL)isEdit success:(void (^)(UIImage *image))success{
    CameraTool *camTool = [self cameraToolDefault];
    camTool.isEdit = isEdit;
    camTool.vc = myVC;
    camTool.type = CameraToolDefault;
    [camTool showActionSheet];
    [myVC.view addSubview:camTool];
    
    __weak CameraTool *cam = camTool;
    camTool.CompleteChooseCallback = ^(UIImage *image){
        [cam removeFromSuperview];
        if (image) {
            SAFE_BLOCK_CALL(success, image);
        }
    };
}

+ (void)cameraAtView:(UIViewController *)myVC imageWidth:(CGFloat)width maxNum:(NSInteger)maxNum success:(void (^)(NSArray *images))success;{
    [self cameraAtView:myVC sourceType:UIImagePickerControllerSourceTypePhotoLibrary imageWidth:width maxNum:maxNum success:success];
}

+ (void)cameraAtView:(UIViewController *)myVC sourceType:(UIImagePickerControllerSourceType)type imageWidth:(CGFloat)width maxNum:(NSInteger)maxNum success:(void (^)(NSArray *images))success{
    if (maxNum <= 0) {
        return;
    }
    CameraTool *camTool = [self cameraToolDefault];
    camTool.vc = myVC;
    camTool.type = CameraToolCustomize;
    camTool.maxNum = maxNum;
    camTool.width = width;
    [myVC.view addSubview:camTool];
    
    switch (type) {
        case UIImagePickerControllerSourceTypePhotoLibrary:
            [camTool showActionSheet];
            break;
        case UIImagePickerControllerSourceTypeCamera:
            [camTool goCamera];
            break;
        case UIImagePickerControllerSourceTypeSavedPhotosAlbum:
            [camTool goPhotosPicker];
            break;
        default:
            break;
    }
    
    __weak CameraTool *cam = camTool;
    camTool.photosCompleteChooseCallback = ^(NSArray *images){
        if (images) {
            SAFE_BLOCK_CALL(success, images);
        }
        [cam removeFromSuperview];
    };
}


+ (void)cameraDisableAlert{
    UIAlertView *atView = [[UIAlertView alloc]initWithTitle:@"Unable to open the camera".local_basic message:@"In Settings - > general - > disable access to camera limit access restrictions".local_basic delegate:nil cancelButtonTitle:@"Got it".local_basic otherButtonTitles:nil, nil];
    [atView show];
}

-(void)showActionSheet{
    KKActionSheet *choiceSheet =[[KKActionSheet alloc] initWithTitle:nil
                                                          titleColor:[UIColor colorWithHexString:@"333333"]
                                                        buttonTitles:@[@"Photograph".local_basic, @"Select from the album".local_basic]
                                                      redButtonIndex:-1 defColor:@[@3,@4] delegate:self];
    [choiceSheet show];
    //    [choiceSheet showInView:self.vc.view];
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(KKActionSheet *)actionSheet didClickedButtonAtIndex:(int)buttonIndex{
    
    if (buttonIndex == 2) return;
    
    if (self.type == CameraToolDefault) {
        
        UIImagePickerControllerSourceType type = UIImagePickerControllerSourceTypePhotoLibrary;
        if([UIImagePickerController isSourceTypeAvailable:type]){
            if( buttonIndex == 0 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
                type = UIImagePickerControllerSourceTypeCamera;
            }
            if (type==UIImagePickerControllerSourceTypeCamera) {
                SKFCamera *homec=[[SKFCamera alloc]init];
                __weak typeof(self)myself=self;
                homec.fininshcapture=^(UIImage *ss){
                    if (ss) {
                        UIImage *newImage = [myself imageWithImage:ss];
                        if (myself.type == CameraToolDefault) {
                            if (myself.CompleteChooseCallback) {
                                myself.CompleteChooseCallback(newImage);
                            }
                        }
                        else if (myself.type == CameraToolCustomize) {
                            if (myself.photosCompleteChooseCallback) {
                                myself.photosCompleteChooseCallback(@[newImage]);
                            }
                        }
                        
                    }
                } ;
                [self.vc presentViewController:homec animated:NO completion:^{}];
            }else{
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.allowsEditing = self.isEdit;
                picker.delegate = self;
                picker.sourceType = type;
                [self.vc presentViewController:picker animated:YES completion:nil];
            }
            
        }
    }
    else if (self.type == CameraToolCustomize) {
        if (buttonIndex == 0) {
            [self goCamera];
            
        } else  if (buttonIndex == 1) {
            [self goPhotosPicker];
        }
    }
}

- (void)goCamera{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        // 跳相机
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.allowsEditing = NO;
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self.vc presentViewController:picker animated:YES completion:nil];
    } else {
        [CameraTool cameraDisableAlert];
    }
}

- (void)goPhotosPicker{
    // 跳相册
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:self.maxNum delegate:self];
    imagePickerVc.photoWidth=self.width;
    imagePickerVc.barItemTextColor=[UIColor KK_MainColor];
    imagePickerVc.naviBgColor=[UIColor whiteColor];
    imagePickerVc.naviTitleColor=[UIColor KK_Gray33];
    imagePickerVc.allowPickingVideo=NO;
    imagePickerVc.allowPickingGif = YES;
    imagePickerVc.oKButtonTitleColorNormal=[UIColor KK_MainColor];
    [self.vc presentViewController:imagePickerVc animated:YES completion:nil];
}


#pragma mark - KKAssetPickerController Delegate

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto{
    self.photosCompleteChooseCallback(photos);
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingGifImage:(UIImage *)animatedImage sourceAssets:(id)asset{
    self.photosCompleteChooseCallback(@[animatedImage]);
    
    //    NSMutableArray *emptyImages = []
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    UIImage *image = [info objectForKey:_isEdit?UIImagePickerControllerEditedImage:UIImagePickerControllerOriginalImage];
    if (image) {
        [picker dismissViewControllerAnimated:YES completion:^{
            UIImage *newImage = [self imageWithImage:image];
            if (self.type == CameraToolDefault) {
                if (self.CompleteChooseCallback) {
                    self.CompleteChooseCallback(newImage);
                }
            }
            else if (self.type == CameraToolCustomize) {
                if (self.photosCompleteChooseCallback) {
                    self.photosCompleteChooseCallback(@[newImage]);
                }
            }
            
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        }];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:^{
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }];
}

-(UIImage*)imageWithImage:(UIImage*)image
{
    float Proportion = image.size.width/image.size.height;
    CGSize newSize = CGSizeMake(self.width, self.width/Proportion);
    
    if (image.size.width > self.width) {
        UIGraphicsBeginImageContext(newSize);
        [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
        image  = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return image;
}

@end
