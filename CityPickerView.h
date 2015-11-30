//
//  CityPickerView.h
//  WMALL
//
//  Created by HanLiu on 15/11/12.
//  Copyright © 2015年 wjhg. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ConfirmBlock)(NSString *province,NSString *city,NSString *area);

@interface CityPickerView : UIView

@property (nonatomic,copy)ConfirmBlock confirmBlock;

- (void)popupPickerView;
- (void)closePickerView;
@end
