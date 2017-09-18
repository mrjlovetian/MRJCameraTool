//
//  MRJCameraTool.h
//  Pods
//
//  Created by Mr on 2017/9/18.
//
//

#import <UIKit/UIKit.h>
typedef enum CameraToolType
{
    CameraToolDefault = 0, // 系统相册
    CameraToolCustomize,   // 自定义
    
} CameraToolType;

@interface MRJCameraTool : UIView
@property (nonatomic, assign) UIImagePickerControllerSourceType sourceType;
@property (nonatomic, assign) BOOL isEdit;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CameraToolType type;
@property (nonatomic, assign) NSInteger maxNum;
@property (nonatomic, weak) UIViewController *vc;
@property (nonatomic, copy) void (^CompleteChooseCallback)(UIImage *image);
@property (nonatomic, copy) void (^photosCompleteChooseCallback)(NSArray *images);

- (void)showActionSheet;
+ (void)cameraDisableAlert;

/*系统相机封装
 *@param myVc
 *@param isEdit 是否编辑
 *@param success 返回image对象
 */
+ (void)cameraAtView:(UIViewController *)myVC isEdit:(BOOL)isEdit success:(void (^)(UIImage *image))success;

/*自定义选择图片封装
 *@param myVc
 *@param width 图片分辨率宽度，px
 *@param maxNum 最多可以选择多少张
 *@param success 返回image数组对象
 */
+ (void)cameraAtView:(UIViewController *)myVC imageWidth:(CGFloat)width maxNum:(NSInteger)maxNum success:(void (^)(NSArray *images))success;

/*自定义选择图片封装
 *@param myVc
 *@param type 默认从相册和相机获取
 *@param width 图片分辨率宽度，px
 *@param maxNum 最多可以选择多少张
 *@param success 返回image数组对象
 */

+ (void)cameraAtView:(UIViewController *)myVC sourceType:(UIImagePickerControllerSourceType)type imageWidth:(CGFloat)width maxNum:(NSInteger)maxNum success:(void (^)(NSArray *images))success;
@end
