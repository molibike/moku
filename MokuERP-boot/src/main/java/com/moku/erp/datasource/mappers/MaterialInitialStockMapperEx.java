package com.moku.erp.datasource.mappers;

import com.moku.erp.datasource.entities.MaterialCurrentStock;
import com.moku.erp.datasource.entities.MaterialInitialStock;
import com.moku.erp.datasource.entities.MaterialInitialStockExample;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface MaterialInitialStockMapperEx {

    int batchInsert(List<MaterialInitialStock> list);

    List<MaterialInitialStock> getListExceptZero();

    void batchDeleteByDepots(@Param("ids") String ids[]);
}