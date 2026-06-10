package com.moku.erp.datasource.mappers;

import com.moku.erp.datasource.entities.SystemConfig;
import com.moku.erp.datasource.entities.SystemConfigExample;
import org.apache.ibatis.annotations.Param;

import java.util.Date;
import java.util.List;

public interface SystemConfigMapperEx {

    List<SystemConfig> selectByConditionSystemConfig(
            @Param("companyName") String companyName,
            @Param("offset") Integer offset,
            @Param("rows") Integer rows);

    Long countsBySystemConfig(
            @Param("companyName") String companyName);

    int batchDeleteSystemConfigByIds(@Param("updateTime") Date updateTime, @Param("updater") Long updater, @Param("ids") String ids[]);
}