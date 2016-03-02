//
//  PasswordBuild.m
//  PayInPwdDemo
//
//  Created by IOS-Sun on 16/2/29.
//  Copyright © 2016年 IOS-Sun. All rights reserved.
//

#import "PasswordBuild.h"
#import "PayDetailInfo.h"
#import "PayInputView.h"
#import "CALayer+Shake.h"

#define TITLE_HEIGHT 46
#define PAYMENT_WIDTH [UIScreen mainScreen].bounds.size.width-80
#define PWD_COUNT 6
#define DOT_WIDTH 10
#define KEYBOARD_HEIGHT 216
#define KEY_VIEW_DISTANCE 50
#define ALERT_HEIGHT 300

#define KEY_WIDTH 49

@interface PasswordBuild () {
    NSMutableArray *inputZones;
    NSMutableArray *labelZones;
    NSMutableArray *alertZones;
}

@property (nonatomic, strong) UILabel * inputLabel, *reInitLabel,*finalLabel;

@property (nonatomic, strong) UILabel * alertInput, *alertFinal;

@property (nonatomic, strong) PayDetailInfo * passwordView;

@property (nonatomic, strong) PayInputView  * inputPwd, *reInitPwd, *finalPwd;

@end


@implementation PasswordBuild

- (instancetype)init {
    self = [self initWithFrame:[UIScreen mainScreen].bounds];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.3f];
        
        [self drawView];
        [self createDefaultData];
        
        [self setNeedsLayout];
    }
    return self;
}


/**
 *  添加block
 */
- (void)createDefaultData {
    
    self.passwordView.title = @"创建支付密码";
    [self.passwordView.detailTable removeFromSuperview];
    
    self.pwdOperationType = PwdOperationTypeCreate;
    
    __weak typeof(self)weakSelf = self;
    self.inputPwd.completeHandle = ^(NSString *inputPwd){
        NSLog(@"创建或者验证：%@",inputPwd);
        
        if (weakSelf.pwdOperationType == PwdOperationTypeCreate) {
            [weakSelf dismiss];
        } else {
            weakSelf.PwdInput(inputPwd);
        }
    };
    
    self.reInitPwd.completeHandle = ^(NSString *inputPwd){
        NSLog(@"重新设置输入：%@",inputPwd);
    };
    
    self.finalPwd.completeHandle = ^(NSString *inputPwd){
        NSLog(@"再次输入：%@",inputPwd);
        //如果输入不同，清除
    };
    
    self.passwordView.dismissBtnBlock = ^(){
        [weakSelf dismiss];
    };
    
}


/**
 *  判断原密码是否输入正确
 *
 *  @param isCorrect 是否正确
 */
- (void)verifyPwdisCorrect:(BOOL)isCorrect {
    
    self.alertInput.hidden = isCorrect;
    
//    self.reInitPwd.pwdTextField.enabled = isCorrect;
//    self.finalPwd.pwdTextField.enabled = isCorrect;
    
    if (isCorrect) {
        //如果正确
        [self.inputPwd.pwdTextField resignFirstResponder];
        
        /*
         self.inputPwd.pwdTextField.text = nil;
         
         self.reInitPwd.pwdTextField.text = nil;
         
        [self.reInitPwd setDotWithCount:0];
        
        self.finalPwd.pwdTextField.text = nil;
        [self.finalPwd setDotWithCount:0];
        */
        
        [self performSelectorOnMainThread:@selector(changeFrame) withObject:self.passwordView waitUntilDone:YES];
        
    } else {
        //如果错误
        [self.alertInput.layer shake];
    }
}


- (void)changeFrame{
    
    CGFloat pwdBottom = self.passwordView.bounds.size.height - (self.reInitPwd.frame.origin.y + self.reInitPwd.frame.size.height);
    BOOL isUp =  pwdBottom > KEYBOARD_HEIGHT?YES:NO;
    if (!isUp) {
        CGFloat upHeight = KEYBOARD_HEIGHT - pwdBottom;
        CGRect passFrame = self.passwordView.frame;
        passFrame.origin.y -= upHeight;
        [UIView animateWithDuration:.2f
                         animations:^{
                             self.passwordView.frame = passFrame;
                             [self addSubview:self.passwordView];
                             [self.reInitPwd.pwdTextField becomeFirstResponder];
                         }];
    }
}

/**
 *  绘制默认视图
 */
- (void)drawView {
    if (!self.passwordView) {
        inputZones = [[NSMutableArray alloc] init];
        labelZones = [[NSMutableArray alloc] init];
        alertZones = [[NSMutableArray alloc] init];
        
        //创建密码
        self.inputPwd = [self createInputView];
        self.inputPwd.tag = 141;
        [inputZones addObject:self.inputPwd];
//        [self.passwordView addSubview:self.inputPwd];
        
        //左侧提示文
        self.inputLabel = [self createInputLabel];
        self.inputLabel.tag = 161;
        self.inputLabel.text = @"请输入新密码";
        [labelZones addObject:self.inputLabel];
        
        self.alertInput = [self createInputLabel];
        self.alertInput.tag = 164;
        self.alertInput.text = @"原密码输入错误";
        self.alertInput.textColor = [UIColor redColor];
        self.alertInput.hidden = YES;
        [alertZones addObject:self.alertInput];
        
        //输入新密码
        self.reInitPwd = [self createInputView];
        self.reInitPwd.tag = 142;
        [inputZones addObject:self.reInitPwd];
//        [self.passwordView addSubview:self.reInitPwd];
        
        self.reInitLabel = [self createInputLabel];
        self.reInitLabel.tag = 162;
        self.reInitLabel.text = @"请输入新密码";
        [labelZones addObject:self.reInitLabel];
        
        //再次输入新密码
        self.finalPwd = [self createInputView];
        self.finalPwd.tag = 143;
        [inputZones addObject:self.finalPwd];
//        [self.passwordView addSubview:self.finalPwd];
        
        self.finalLabel = [self createInputLabel];
        self.finalLabel.tag = 163;
        self.finalLabel.text = @"请确认密码";
        [labelZones addObject:self.finalLabel];
        
        self.alertFinal = [self createInputLabel];
        self.alertFinal.tag = 165;
        self.alertFinal.text = @"输入不同，请重新输入";
        self.alertFinal.textColor = [UIColor redColor];
        self.alertFinal.hidden = YES;
        [alertZones addObject:self.alertFinal];
        
        self.passwordView = [[PayDetailInfo alloc] initWithFrame:CGRectZero];
        self.passwordView.tag = 151;
        [self addSubview:self.passwordView];
    }
}

- (PayInputView *)createInputView {
    PayInputView * inputPwd = [[PayInputView alloc] initWithFrame:CGRectZero];
    inputPwd.backgroundColor = [UIColor whiteColor];
    inputPwd.layer.borderWidth = 1.f;
    inputPwd.layer.borderColor =  [UIColor colorWithRed:.9 green:.9 blue:.9 alpha:1.].CGColor;
    return inputPwd;
}

- (UILabel *)createInputLabel {
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.textColor = [UIColor darkGrayColor];
    label.font = [UIFont systemFontOfSize:14.f];
    return label;
}

/**
 *  弹出界面
 */
- (void)show {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    
    //实现放大的弹簧效果
    self.passwordView.transform = CGAffineTransformMakeScale(1.21f, 1.21f);
    self.passwordView.alpha = 0;
    
    [UIView animateWithDuration:.7f delay:0.f usingSpringWithDamping:.7f initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        [self.inputPwd.pwdTextField becomeFirstResponder];
        self.passwordView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        self.passwordView.alpha = 1.0;
    } completion:nil];
}

/**
 *  当前视图消失
 */
- (void)dismiss {
    [UIView animateWithDuration:0.3f animations:^{
        self.passwordView.transform = CGAffineTransformMakeScale(1.21f, 1.21f);
        self.passwordView.alpha = 0;
        
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if ((self.pwdCount < 4) && (self.pwdCount > 8)) {
        self.pwdCount = 6;
    }
    CGFloat pwdXpiex,pwdYpiex,pwdWidth,pwdHeight;
    pwdXpiex = 0;
    pwdWidth = self.bounds.size.width;
    pwdHeight = (PAYMENT_WIDTH - 30)/6 + 250 + 15 + TITLE_HEIGHT;
    pwdYpiex = [UIScreen mainScreen].bounds.size.height - pwdHeight;
    
    CGFloat inputWidth = KEY_WIDTH * self.pwdCount;
    if (self.pwdCount < 6) {
        inputWidth = (KEY_WIDTH + 10) * self.pwdCount;
    }
//    CGFloat labelXpiex = 10;
    CGFloat labelWidth = self.frame.size.width*.5;
    
    CGFloat inputHeight = (PAYMENT_WIDTH-30)/6;
    CGFloat inputXpiex = (self.frame.size.width - inputWidth)*.5;
    CGFloat inputYpiex;
    CGRect pwdFrame,inputFrame;
    
    CGFloat alertXpiex = self.frame.size.width*.5;
    CGFloat alertWidth = self.frame.size.width*.5 - 10;
    
    if (self.passwordView.frame.size.height == 0) {
        pwdFrame = CGRectMake(pwdXpiex, pwdYpiex, pwdWidth, pwdHeight);
        self.passwordView.frame = pwdFrame;
    }
//    pwdFrame = CGRectMake(pwdXpiex, pwdYpiex, pwdWidth, pwdHeight);
//    self.passwordView.frame = pwdFrame;
    
    self.inputPwd.pwdCount = self.pwdCount;
    
    switch (self.pwdOperationType) {
        case PwdOperationTypeCreate:{
            inputYpiex = TITLE_HEIGHT + 10;
            self.inputLabel.frame = CGRectMake(inputXpiex, inputYpiex, labelWidth, inputHeight);
            [self.passwordView addSubview:self.inputLabel];
            
            inputFrame = CGRectMake(inputXpiex, inputYpiex+inputHeight*.8, inputWidth, inputHeight);
            self.inputPwd.frame = inputFrame;
            [self.passwordView addSubview:self.inputPwd];
        }
            break;
        case PwdOperationTypeReset:{
            self.reInitPwd.pwdCount = self.pwdCount;
            self.finalPwd.pwdCount = self.pwdCount;
            
            CGFloat interPwdHeight = (pwdHeight - TITLE_HEIGHT - 3*inputHeight)/4;
            NSLog(@"%f",interPwdHeight);
            
            inputYpiex = TITLE_HEIGHT + 10;
            self.inputLabel.text = @"请输入原密码";
            
            [labelZones enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                UILabel * label = (UILabel *)obj;
                CGFloat inYpiex = inputYpiex + (interPwdHeight+inputHeight)*idx;
                label.frame = CGRectMake(inputXpiex, inYpiex, labelWidth, inputHeight);
                [self.passwordView addSubview:label];
                
                if (idx == 0) {
                    self.alertInput.frame = CGRectMake(alertXpiex, inYpiex, alertWidth, inputHeight);
                    [self.passwordView addSubview:self.alertInput];
                } else if (idx == 2) {
                    self.alertFinal.frame = CGRectMake(alertXpiex, inYpiex, alertWidth, inputHeight);
                    [self.passwordView addSubview:self.alertFinal];
                }
            }];
            
            //PayInputView  * inputPwd, *reInitPwd, *finalPwd;
            [inputZones enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                PayInputView * inputPwd = (PayInputView *)obj;
                CGFloat inYpiex = inputYpiex + interPwdHeight*.8 + (interPwdHeight+inputHeight)*idx;
                inputPwd.frame = CGRectMake(inputXpiex, inYpiex, inputWidth, inputHeight);
                [self.passwordView addSubview:inputPwd];
            }];
            
        }
            break;
            
        default:
            break;
    }

    [self.inputPwd refreshInputViews];
    [self.reInitPwd refreshInputViews];
    [self.finalPwd refreshInputViews];
    
}



@end