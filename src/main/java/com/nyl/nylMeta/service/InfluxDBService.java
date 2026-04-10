package com.nyl.nylMeta.service;

import com.influxdb.client.InfluxDBClient;
import com.influxdb.client.QueryApi;
import com.influxdb.query.FluxTable;
import com.nyl.nylMeta.common.ApiResponse;
import com.nyl.nylMeta.common.ApiResponse.DataPoint;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class InfluxDBService {

    @Autowired
    private InfluxDBClient influxDBClient;
    public ApiResponse executeQuery(String database, String entityId, String measurement, String startTime, String endTime, String density, String aggregation, Integer limit) {
        String bucket = database;
        String fluxQuery = buildFluxQuery(bucket, entityId, measurement, startTime, endTime, density, aggregation, limit);
        
        List<DataPoint> dataPoints = executeFluxQuery(fluxQuery);
        return new ApiResponse(200, dataPoints, fluxQuery);
    }

    public String generateFluxQuery(String database, String entityId, String measurement, String startTime, String endTime, String density, String aggregation, Integer limit) {
        String bucket = database ;
        return buildFluxQuery(bucket, entityId, measurement, startTime, endTime, density, aggregation, limit);
    }

    private String buildFluxQuery(String bucket, String entityId, String measurement, String startTime, String endTime, String density, String aggregation, Integer limit) {
        StringBuilder flux = new StringBuilder();
        flux.append("from(bucket: \"").append(bucket).append("\")\n");
        flux.append("  |> range(start: time(v: \"").append(startTime).append("\"), stop: time(v: \"").append(endTime).append("\"))\n");
        
        if (entityId != null && !entityId.isEmpty()) {
            flux.append("  |> filter(fn: (r) => r[\"entity_id\"] == \"").append(entityId).append("\")\n");
        }
        
        flux.append("  |> filter(fn: (r) => r[\"_field\"] == \"value\")\n");
        flux.append("  |> filter(fn: (r) => r[\"_measurement\"] == \"").append(measurement).append("\")\n");
        
        if (density != null && !density.isEmpty()) {
            String aggFunction = aggregation != null && !aggregation.isEmpty() ? aggregation : "last";
            flux.append("  |> aggregateWindow(every: ").append(density).append(", fn: ").append(aggFunction).append(", createEmpty: false)\n");
        }
        
        if (limit != null && limit > 0) {
            flux.append("  |> limit(n: ").append(limit).append(")\n");
        }
        
        flux.append("  |> yield(name: \"raw\")\n");
        
        return flux.toString();
    }

    private List<DataPoint> executeFluxQuery(String fluxQuery) {
        List<DataPoint> dataPoints = new ArrayList<>();
        QueryApi queryApi = influxDBClient.getQueryApi();
        
        List<FluxTable> tables = queryApi.query(fluxQuery);
        for (FluxTable table : tables) {
            table.getRecords().forEach(record -> {
                DataPoint dataPoint = new DataPoint(
                    record.getTime().toString(),
                    record.getValue()
                );
                dataPoints.add(dataPoint);
            });
        }
        
        return dataPoints;
    }

    public List<String> getFields() {
        // 这里可以从配置文件或数据库读取单位列表
        // 暂时返回静态列表
        List<String> measurements = new ArrayList<>();
        measurements.add("m3");
        measurements.add("kWh");
        measurements.add("kg");
        measurements.add("℃");
        measurements.add("%");
        return measurements;
    }

    public ApiResponse executeCustomFlux(String fluxQuery) {
        List<DataPoint> dataPoints = executeFluxQuery(fluxQuery);
        return new ApiResponse(200, dataPoints, fluxQuery);
    }
}
