package com.moku.erp.datasource.mappers;

import com.moku.erp.datasource.entities.MaterialCurrentStock;
import com.moku.erp.datasource.entities.MaterialCurrentStockExample;
import org.apache.ibatis.annotations.Param;

import java.math.BigDecimal;
import java.util.List;

public interface MaterialCurrentStockMapperEx {

    int batchInsert(List<MaterialCurrentStock> list);

    List<MaterialCurrentStock> getCurrentStockMapByIdList(
            @Param("materialIdList") List<Long> materialIdList);

    void updateUnitPriceByMId(
            @Param("currentUnitPrice") BigDecimal currentUnitPrice,
            @Param("materialId") Long materialId);

    BigDecimal getCurrentUnitPriceByMId(@Param("materialId") Long materialId);

    void batchDeleteByDepots(@Param("ids") String ids[]);
}