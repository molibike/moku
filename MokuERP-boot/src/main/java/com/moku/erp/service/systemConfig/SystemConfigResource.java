package com.moku.erp.service.systemConfig;

import com.moku.erp.service.ResourceInfo;

import java.lang.annotation.*;

/**
 * @author jishenghua 2018-10-7 15:26:27
 */
@ResourceInfo(value = "systemConfig")
@Inherited
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
public @interface SystemConfigResource {
}
