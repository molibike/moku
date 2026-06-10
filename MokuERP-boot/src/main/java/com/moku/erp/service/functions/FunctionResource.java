package com.moku.erp.service.functions;

import com.moku.erp.service.ResourceInfo;

import java.lang.annotation.*;

/**
 * @author jishenghua 2018-10-7 15:26:27
 */
@ResourceInfo(value = "function")
@Inherited
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
public @interface FunctionResource {
}
