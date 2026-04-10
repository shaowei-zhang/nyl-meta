package com.nyl.nylMeta.common;

import java.util.List;

public class ApiResponse {
    private int code;
    private List<DataPoint> data;
    private String flux;

    public ApiResponse(int code, List<DataPoint> data, String flux) {
        this.code = code;
        this.data = data;
        this.flux = flux;
    }

    public int getCode() {
        return code;
    }

    public void setCode(int code) {
        this.code = code;
    }

    public List<DataPoint> getData() {
        return data;
    }

    public void setData(List<DataPoint> data) {
        this.data = data;
    }

    public String getFlux() {
        return flux;
    }

    public void setFlux(String flux) {
        this.flux = flux;
    }

    public static class DataPoint {
        private String _time;
        private Object _value;

        public DataPoint(String _time, Object _value) {
            this._time = _time;
            this._value = _value;
        }

        public String get_time() {
            return _time;
        }

        public void set_time(String _time) {
            this._time = _time;
        }

        public Object get_value() {
            return _value;
        }

        public void set_value(Object _value) {
            this._value = _value;
        }
    }
}
