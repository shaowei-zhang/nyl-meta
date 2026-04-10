package com.nyl.nylMeta.controller;

import com.nyl.nylMeta.EnergyEnums;
import com.nyl.nylMeta.common.ApiResponse;
import com.nyl.nylMeta.model.QueryRequest;
import com.nyl.nylMeta.service.InfluxDBService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.List;
import java.util.Map;

@Controller
public class InfluxDBController {

    @Autowired
    private InfluxDBService influxDBService;

    @GetMapping({"/", "/query"})
    public String queryPage() {
        return "query";
    }

    @PostMapping("/api/query")
    @ResponseBody
    public ApiResponse executeQuery(@RequestBody QueryRequest request) {
        return influxDBService.executeQuery(
                request.getDatabase(),
                request.getEntity_id(),
                request.getMeasurement(),
                request.getStart_time(),
                request.getEnd_time(),
                request.getDensity(),
                request.getAggregation(),
                request.getLimit()
        );
    }

    @GetMapping("/api/fields")
    @ResponseBody
    public List<String> getFields() {
        return influxDBService.getFields();
    }

    @PostMapping("/api/raw/flux")
    @ResponseBody
    public String generateFlux(@RequestBody QueryRequest request) {
        return influxDBService.generateFluxQuery(
                request.getDatabase(),
                request.getEntity_id(),
                request.getMeasurement(),
                request.getStart_time(),
                request.getEnd_time(),
                request.getDensity(),
                request.getAggregation(),
                request.getLimit()
        );
    }

    @PostMapping("/api/execute/flux")
    @ResponseBody
    public ApiResponse executeCustomFlux(@RequestBody String fluxQuery) {
        return influxDBService.executeCustomFlux(fluxQuery);
    }

    @PostMapping("/api/execute/raw")
    @ResponseBody
    public ApiResponse executeRawFlux(@RequestBody String fluxQuery) {
        return influxDBService.executeCustomFlux(fluxQuery);
    }

    @PostMapping("/api/getEntityIdMap")
    @ResponseBody
    public Map<String, String> getEntityIdMap() {
        Map<String, String> map = EnergyEnums.toMap();
        return map;
    }
}
