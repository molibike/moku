package com.moku.erp.service.accountItem;

import com.moku.erp.service.ResourceInfo;

import java.lang.annotation.*;

/**
 * @author jishenghua 2018-10-7 15:26:27
 */
@ResourceInfo(value = "accountItem")
@Inherited
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
public @interface AccountItemResource {
}
