//
//  MyViewController.m
//  MobileHospital
//
//  Created by ZY on 2018/7/3.
//  Copyright © 2018年 ZY. All rights reserved.
//

#import "MyViewController.h"
#import "MyWorkViewController.h"
#import <StoreKit/StoreKit.h>

@interface MyViewController ()<SKStoreProductViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *userImg;
@property (weak, nonatomic) IBOutlet UILabel *userNameLab;
@property (weak, nonatomic) IBOutlet UILabel *keshiLab;
@property (weak, nonatomic) IBOutlet UILabel *softVerLab;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet UIView *myWorkItem;
@property (weak, nonatomic) IBOutlet UIView *clearCache;
@property (weak, nonatomic) IBOutlet UILabel *cacheSizeLab;
@property (weak, nonatomic) IBOutlet UIView *aboutMeView;
@property (weak, nonatomic) IBOutlet UIButton *supportBtn;



@end

@implementation MyViewController

-(instancetype)init{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MySB" bundle:nil];
    self = [storyboard instantiateViewControllerWithIdentifier:@"MyViewController"];
    if (self) {
        // Custom initialization
        self.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"我的" image:[[UIImage imageNamed:@"my_noCheckTabBar"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"my_checkTabBar"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];

        self.title = @"我的";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSDictionary * infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [NSString stringWithFormat:@"V%@",[infoDic objectForKey:@"CFBundleShortVersionString"]];
    _softVerLab.text = app_Version;
    _keshiLab.userInteractionEnabled = YES;
    UITapGestureRecognizer * gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickNickName)];
    [_keshiLab addGestureRecognizer:gesture];
    _userImg.userInteractionEnabled = YES;
    UITapGestureRecognizer * imgGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickUserImg)];
    [_userImg addGestureRecognizer:imgGesture];
    UITapGestureRecognizer * myWorkGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickMyWork)];
    [_myWorkItem addGestureRecognizer:myWorkGesture];
    UITapGestureRecognizer * clearCacheGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickClearCache)];
    [_clearCache addGestureRecognizer:clearCacheGesture];
    UITapGestureRecognizer * aboutMeGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickaboutMe)];
    [_aboutMeView addGestureRecognizer:aboutMeGesture];
    
    _supportBtn.layer.borderWidth = 1.0f;
    _supportBtn.layer.borderColor = [UIColor colorWithRed:237/255.0 green:237/255.0 blue:237/255.0 alpha:1.0].CGColor;
    _supportBtn.layer.cornerRadius = 6.0f;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    __weak typeof(self) vc = self;
    BmobUser *bUser = [BmobUser currentUser];
    if (bUser) {
        UserProfile *user = [[UserProfile alloc] initFromBmobObject:[BmobUser currentUser]];
        //进行操作
        _userNameLab.text = bUser.username;
        _keshiLab.text = [NSString stringWithFormat:@"昵称:%@",[NSString isStringNull:user.nickName]];
        [vc.userImg sd_setImageWithURL:[NSURL URLWithString:user.userImage] placeholderImage:[UIImage imageNamed:@"noSexDoc"]];
        [_registerBtn setTitle:@"注销" forState:UIControlStateNormal];

//        BmobQuery *query = [BmobUser query];
//        [query whereKey:@"username" equalTo:bUser.username];
//        [query getObjectInBackgroundWithId:[NSString stringWithFormat:@"%@-%@",bUser.username,@"userImage.png"] block:^(BmobObject *object, NSError *error) {
//            if (error) {
//                NSLog(@"%@",error);
//            } else {
//                BmobFile *file = (BmobFile *)[object objectForKey:@"filetype"];
//                NSLog(@"%@",file.url);
//            }
//        }];
        
    }else{
        _userNameLab.text = @"请登录";
        _keshiLab.text = @"";
        [_registerBtn setTitle:@"登录" forState:UIControlStateNormal];
    }
    
    float tmpSize = [[SDImageCache sharedImageCache] getSize];
    _cacheSizeLab.text = [NSString stringWithFormat:@"%.1fM",tmpSize/1024/1024];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

-(void)clickNickName
{
    BmobUser *bUser = [BmobUser currentUser];
    if (!bUser) {
        [[AppDelegate appDelegate] showLoginNav];
        return;
    }
    
    UserProfile *user = [[UserProfile alloc] initFromBmobObject:[BmobUser currentUser]];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:user.nickName preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }]];
    //增加确定按钮；
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //获取第1个输入框；
        UITextField *nickNameTextField = alertController.textFields.firstObject;
        
        BmobUser *bUser = [BmobUser currentUser];
        //更新number为30
        [bUser setObject:nickNameTextField.text forKey:@"nickName"];
        [bUser updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
            if(isSuccessful){
                [ToolsFunction showPromptViewWithString:@"修改成功" background:nil timeDuration:1];
                _keshiLab.text = [NSString stringWithFormat:@"昵称:%@",nickNameTextField.text];
            }else{
                NSLog(@"error %@",error.description);
            }
        }];
    }]];
    
    //定义输入框；
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"昵称：";
    }];
    [[ToolsFunction getCurrentRootViewController] presentViewController:alertController animated:true completion:nil];
}

-(void)clickUserImg
{
    BmobUser *bUser = [BmobUser currentUser];
    if (!bUser) {
        [[AppDelegate appDelegate] showLoginNav];
        return;
    }
    
    // 跳转到相机或相册页面
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    UIImagePickerController * picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = sourceType;
    [[ToolsFunction getCurrentRootViewController] presentViewController:picker animated:YES completion:^{}];
}

#pragma mark imagePickerDelegte
//UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
//    [[UIApplication sharedApplication] setStatusBarHidden: NO];
    [picker dismissViewControllerAnimated:YES completion:^{
    }];
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    //刷新图像
    __weak typeof(self) vc = self;
    //处理图片大小进行上传
    NSData *data = UIImagePNGRepresentation(image);
    BmobUser *bUser = [BmobUser currentUser];
    BmobFile *file = [[BmobFile alloc]initWithFileName:[NSString stringWithFormat:@"%@-%@",bUser.username,@"userImage.png"] withFileData:data];
    [file saveInBackground:^(BOOL isSuccessful, NSError *error) {
        //如果文件保存成功，则把文件添加到filetype列
        if (isSuccessful) {
            //上传文件的URL地址
            [bUser setObject:file.url forKey:@"userImage"];
            //此处相当于新建一条记录,         //关联至已有的记录请使用 [obj updateInBackground];
            [bUser updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                if(isSuccessful){
                    [ToolsFunction showPromptViewWithString:@"修改成功" background:nil timeDuration:1];
                    vc.userImg.image = image;
                }else{
                    NSLog(@"error %@",error.description);
                }
            }];
        }else{
            //进行处理
        }
    }];
    
    [picker dismissViewControllerAnimated:YES
                               completion:nil];
}

- (void)clickMyWork{
    //我的作品
    BmobUser *bUser = [BmobUser currentUser];
    if (!bUser) {
        [[AppDelegate appDelegate] showLoginNav];
        return;
    }
    
    MyWorkViewController * myWork = [[MyWorkViewController alloc]init];
    myWork.hidesBottomBarWhenPushed = YES;
    myWork.bUser = bUser;
    [self.navigationController pushViewController:myWork animated:YES];
}

-(void)clickClearCache
{
    //清除缓存
    __weak typeof(self)vc = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"确定要清除缓存吗？" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }]];
    //增加确定按钮；
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[SDImageCache sharedImageCache] clearDisk];
        [ToolsFunction showPromptViewWithString:@"清除成功" background:nil timeDuration:1];
        float tmpSize = [[SDImageCache sharedImageCache] getSize];
        vc.cacheSizeLab.text = [NSString stringWithFormat:@"%.1fM",tmpSize/1024/1024];
    }]];
    [[ToolsFunction getCurrentRootViewController] presentViewController:alertController animated:true completion:nil];
}

-(void)clickaboutMe
{
    [SKStoreReviewController requestReview];

//    SKStoreProductViewController *storeProductViewContorller = [[SKStoreProductViewController alloc] init];
//    // 设置代理请求为当前控制器本身
//    storeProductViewContorller.delegate=self;
//    [storeProductViewContorller loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier:@"1435758672"}completionBlock:^(BOOL result,NSError*error)   {
//        if(error)  {
//            NSLog(@"error %@ with userInfo %@",error,[error userInfo]);
//        }else{
//            // 模态弹出appstore
//            [self presentViewController:storeProductViewContorller animated:YES completion:nil];
//        }
//    }];
}

//AppStore取消按钮监听
- (void)productViewControllerDidFinish:(SKStoreProductViewController*)viewController{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)clickSupportBtn:(id)sender {
    NSString *openURL = @"https://github.com/aaa510665117/StickFigure/blob/master/README.md";
    NSURL *URL = [NSURL URLWithString:openURL];
    /**
     ios 10 以后使用  openURL: options: completionHandler:
     这个函数异步执行，但在主队列中调用 completionHandler 中的回调
     openURL:打开的网址
     options:用来校验url和applicationConfigure是否配置正确，是否可用。
     唯一可用@{UIApplicationOpenURLOptionUniversalLinksOnly:@YES}。
     不需要不能置nil，需@{}为置空。
     ompletionHandler:如不需要可置nil
     **/
    [[UIApplication sharedApplication]openURL:URL options:@{} completionHandler:^(BOOL success) {
    }];
}

- (IBAction)clickSignOutBtn:(id)sender {
    BmobUser *bUser = [BmobUser currentUser];
    if (bUser) {
        //点击退出登录
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil message:@"是否注销该账号？" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [BmobUser logout];
            [_registerBtn setTitle:@"登录" forState:UIControlStateNormal];
            _userNameLab.text = @"请登录";
            _keshiLab.text = @"";
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        
    }else{
        //登录
        [[AppDelegate appDelegate] showLoginNav];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
