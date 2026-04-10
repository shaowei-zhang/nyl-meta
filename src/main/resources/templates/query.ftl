<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>InfluxDB 查询工具</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.6.4.min.js"></script>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        
        .container {
            max-width: 1400px;
            margin: 0 auto;
        }
        
        .main-title {
            color: white;
            text-align: center;
            margin-bottom: 30px;
            font-weight: 300;
            letter-spacing: 2px;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.1);
        }
        
        .card {
            background: white;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            margin-bottom: 25px;
            border: none;
            overflow: hidden;
        }
        
        .card-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px 25px;
            font-weight: 600;
            font-size: 18px;
            border: none;
        }
        
        .card-body {
            padding: 30px;
        }
        
        .form-label {
            font-weight: 500;
            color: #495057;
            margin-bottom: 8px;
        }
        
        .form-control, .form-select {
            border-radius: 8px;
            border: 2px solid #e9ecef;
            padding: 12px 15px;
            font-size: 14px;
            transition: all 0.3s ease;
        }
        
        .form-control:focus, .form-select:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 0 rgba(102, 126, 234, 0.1);
        }
        
        .btn {
            border-radius: 8px;
            padding: 12px 25px;
            font-weight: 500;
            transition: all 0.3s ease;
            border: none;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border: none;
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.3);
        }
        
        .btn-success {
            background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);
            border: none;
        }
        
        .btn-success:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(17, 153, 142, 0.3);
        }
        
        .btn-outline-secondary {
            border: 2px solid #6c757d;
            color: #6c757d;
        }
        
        .btn-outline-secondary:hover {
            background: #6c757d;
            color: white;
        }
        
        .time-buttons {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
            margin-bottom: 15px;
        }
        
        .time-buttons button {
            padding: 8px 16px;
            font-size: 13px;
            border-radius: 20px;
            background: #f8f9fa;
            border: 2px solid #dee2e6;
            color: #495057;
        }
        
        .time-buttons button:hover {
            background: #667eea;
            border-color: #667eea;
            color: white;
            transform: translateY(-2px);
        }
        
        .result-container {
            background: #f8f9fa;
            border-radius: 10px;
            padding: 20px;
            margin-top: 20px;
        }
        
        .flux-display, .json-display {
            background: white;
            border-radius: 8px;
            padding: 15px;
            font-family: 'Courier New', monospace;
            font-size: 13px;
            max-height: 250px;
            overflow-y: auto;
            border: 2px solid #e9ecef;
            white-space: pre-wrap;
            word-break: break-all;
        }
        
        .data-table {
            margin-top: 20px;
            border-radius: 10px;
            overflow: hidden;
        }
        
        .table {
            margin-bottom: 0;
        }
        
        .table thead {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        
        .table thead th {
            border: none;
            padding: 15px;
            font-weight: 500;
        }
        
        .table tbody tr {
            transition: all 0.3s ease;
        }
        
        .table tbody tr:hover {
            background: #f0f4ff;
            transform: scale(1.01);
        }
        
        .table tbody td {
            padding: 12px 15px;
            vertical-align: middle;
        }
        
        .section-title {
            color: #667eea;
            font-weight: 600;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
        }
        
        .section-title::before {
            content: '';
            width: 4px;
            height: 20px;
            background: #667eea;
            margin-right: 10px;
            border-radius: 2px;
        }
        
        .copy-btn {
            position: absolute;
            top: 10px;
            right: 10px;
            padding: 5px 12px;
            font-size: 12px;
            border-radius: 5px;
        }
        
        .result-wrapper {
            position: relative;
        }
        
        .form-text {
            color: #6c757d;
            font-size: 12px;
        }
        
        @media (max-width: 768px) {
            .container {
                padding: 10px;
            }
            
            .card-body {
                padding: 20px;
            }
            
            .time-buttons {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <h1 class="main-title">InfluxDB 数据查询工具</h1>
        
        <div class="row">
            <div class="col-lg-6 mb-4">
                <div class="card">
                    <div class="card-header">
                        <i class="bi bi-sliders"></i> 查询参数
                    </div>
                    <div class="card-body">
                        <form id="queryForm">
                            <div class="row">
                                <div class="col-md-4 mb-3">
                                    <label for="database" class="form-label">数据库选择</label>
                                    <select id="database" class="form-select" required>
                                        <option value="HA" selected>HA</option>
                                        <option value="HA1" selected>HA1</option>
                                    </select>
                                </div>
                                <div class="col-md-4 mb-3">
                                    <label for="measurement" class="form-label">单位选择</label>
                                    <select id="measurement" class="form-select" required>
                                        <option value="">请选择单位</option>
                                    </select>
                                </div>
                                
                                <div class="col-md-4 mb-3">
                                    <label for="entityId" class="form-label">设备选择</label>
                                    <select id="entityId" class="form-select" required>
                                        <option value="">请选择设备</option>
                                    </select>
                                </div>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label">时间范围</label>
                                <div class="time-buttons">
                                    <button type="button" class="btn btn-sm" data-time="1h">最近1小时</button>
                                    <button type="button" class="btn btn-sm" data-time="today">今天</button>
                                    <button type="button" class="btn btn-sm" data-time="yesterday">昨天</button>
                                    <button type="button" class="btn btn-sm" data-time="7d">最近7天</button>
                                </div>
                                <div class="row">
                                    <div class="col-md-6">
                                        <input type="datetime-local" id="startTime" class="form-control" required>
                                    </div>
                                    <div class="col-md-6">
                                        <input type="datetime-local" id="endTime" class="form-control" required>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label for="density" class="form-label">聚合粒度</label>
                                    <select id="density" class="form-select">
                                        <option value="">不聚合</option>
                                        <option value="1m">1分钟</option>
                                        <option value="5m">5分钟</option>
                                        <option value="1h">1小时</option>
                                        <option value="1d">1天</option>
                                    </select>
                                </div>
                                
                                <div class="col-md-6 mb-3">
                                    <label for="aggregation" class="form-label">聚合函数</label>
                                    <select id="aggregation" class="form-select">
                                        <option value="last">last</option>
                                        <option value="mean">mean</option>
                                        <option value="max">max</option>
                                        <option value="min">min</option>
                                        <option value="sum">sum</option>
                                    </select>
                                </div>
                            </div>
                            
                            <div class="mb-3">
                                <label for="limit" class="form-label">返回点数限制</label>
                                <input type="number" id="limit" class="form-control" placeholder="可选，默认无限制">
                            </div>
                            
                            <button type="button" id="generateBtn" class="btn btn-primary w-100">
                                <i class="bi bi-magic"></i> 生成 Flux 和入参
                            </button>
                        </form>
                    </div>
                </div>
            </div>
            
            <div class="col-lg-6 mb-4">
                <div class="card">
                    <div class="card-header">
                        <i class="bi bi-code-slash"></i> 生成结果
                    </div>
                    <div class="card-body">
                        <div class="mb-4 result-wrapper">
                            <h6 class="section-title">Flux 查询语句</h6>
                            <div id="fluxDisplay" class="flux-display">等待生成...</div>
                            <button id="copyFluxBtn" class="btn btn-outline-secondary copy-btn">复制</button>
                        </div>
                        
                        <div class="result-wrapper">
                            <h6 class="section-title">入参 JSON</h6>
                            <div id="jsonDisplay" class="json-display">等待生成...</div>
                            <button id="copyJsonBtn" class="btn btn-outline-secondary copy-btn">复制</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="card">
            <div class="card-header">
                <i class="bi bi-play-circle"></i> 执行查询
            </div>
            <div class="card-body">
                <div class="row">
                    <div class="col-md-4 mb-3">
                        <label for="apiUrl" class="form-label">接口地址</label>
                        <input type="text" id="apiUrl" class="form-control" value="/api/query" placeholder="输入接口地址">
                        <small class="form-text">可用接口：/api/query, /api/execute/flux, /api/execute/raw</small>
                    </div>
                    
                    <div class="col-md-8 mb-3">
                        <label for="requestBody" class="form-label">请求体</label>
                        <textarea id="requestBody" class="form-control" rows="4" placeholder="输入请求体 JSON"></textarea>
                        <small class="form-text">
                            /api/query 和 /api/raw/flux 使用 QueryRequest JSON 格式<br>
                            /api/execute/flux 和 /api/execute/raw 使用 Flux 语句文本
                        </small>
                    </div>
                </div>
                
                <div class="d-flex gap-2">
                    <button type="button" id="executeBtn" class="btn btn-success">
                        <i class="bi bi-play-fill"></i> 执行查询
                    </button>
                    <button type="button" id="clearBtn" class="btn btn-outline-secondary">
                        <i class="bi bi-trash"></i> 清空结果
                    </button>
                </div>
            </div>
        </div>
        
        <div id="resultContainer" class="card" style="display: none;">
            <div class="card-header">
                <i class="bi bi-graph-up"></i> 查询结果
            </div>
            <div class="card-body">
                <pre id="resultDisplay" class="flux-display"></pre>
            </div>
        </div>
        
        <div id="tableContainer" class="card data-table" style="display: none;">
            <div class="card-header">
                <i class="bi bi-table"></i> 数据表格
            </div>
            <div class="card-body p-0">
                <table id="dataTable" class="table">
                    <thead>
                        <tr>
                            <th>时间</th>
                            <th>值</th>
                        </tr>
                    </thead>
                    <tbody id="dataBody"></tbody>
                </table>
            </div>
        </div>
    </div>

    <script>
        $(document).ready(function() {
            loadFields();
            setTimeRange('1h');
            
            $('.time-buttons button').click(function() {
                setTimeRange($(this).data('time'));
            });
            
            $('#generateBtn').click(function() {
                generateFluxAndJson();
            });
            
            $('#executeBtn').click(function() {
                executeQuery();
            });
            
            $('#clearBtn').click(function() {
                $('#resultContainer').hide();
                $('#tableContainer').hide();
                $('#dataBody').empty();
            });
            
            $('#copyFluxBtn').click(function() {
                const fluxQuery = $('#fluxDisplay').text();
                if (fluxQuery !== '等待生成...') {
                    navigator.clipboard.writeText(fluxQuery).then(function() {
                        alert('已复制到剪贴板');
                    });
                }
            });
            
            $('#copyJsonBtn').click(function() {
                const jsonText = $('#jsonDisplay').text();
                if (jsonText !== '等待生成...') {
                    navigator.clipboard.writeText(jsonText).then(function() {
                        alert('已复制到剪贴板');
                    });
                }
            });
        });
        
        function loadFields() {
            $.get('/api/fields', function(data) {
                const select = $('#measurement');
                select.empty();
                select.append('<option value="">请选择单位</option>');
                data.forEach(function(field) {
                    select.append('<option value="' + field + '">' + field + '</option>');
                });
            });
            
            loadEntityIds();
        }
        
        function loadEntityIds() {
            $.ajax({
                url: '/api/getEntityIdMap',
                type: 'POST',
                contentType: 'application/json',
                success: function(data) {
                    const select = $('#entityId');
                    select.empty();
                    select.append('<option value="">请选择设备</option>');
                    for (const [entityId, description] of Object.entries(data)) {
                        select.append('<option value="' + entityId + '">' + description + '</option>');
                    }
                },
                error: function(xhr, status, error) {
                    alert('加载设备列表失败: ' + error);
                }
            });
        }
        
        function setTimeRange(range) {
            const now = new Date();
            let startTime;
            
            switch(range) {
                case '1h':
                    startTime = new Date(now.getTime() - 60 * 60 * 1000);
                    break;
                case 'today':
                    startTime = new Date(now.getFullYear(), now.getMonth(), now.getDate());
                    break;
                case 'yesterday':
                    startTime = new Date(now.getFullYear(), now.getMonth(), now.getDate() - 1);
                    now.setDate(now.getDate() - 1);
                    break;
                case '7d':
                    startTime = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
                    break;
            }
            
            $('#startTime').val(formatDateTime(startTime));
            $('#endTime').val(formatDateTime(now));
        }
        
        function formatDateTime(date) {
            const year = date.getFullYear();
            const month = String(date.getMonth() + 1).padStart(2, '0');
            const day = String(date.getDate()).padStart(2, '0');
            const hours = String(date.getHours()).padStart(2, '0');
            const minutes = String(date.getMinutes()).padStart(2, '0');
            return year + '-' + month + '-' + day + 'T' + hours + ':' + minutes;
        }
        
        function generateFluxAndJson() {
            const request = {
                database: $('#database').val(),
                entity_id: $('#entityId').val(),
                measurement: $('#measurement').val(),
                start_time: new Date($('#startTime').val()).toISOString(),
                end_time: new Date($('#endTime').val()).toISOString(),
                density: $('#density').val(),
                aggregation: $('#aggregation').val(),
                limit: $('#limit').val() ? parseInt($('#limit').val()) : null
            };
            
            $.ajax({
                url: '/api/raw/flux',
                type: 'POST',
                contentType: 'application/json',
                data: JSON.stringify(request),
                success: function(fluxQuery) {
                    $('#fluxDisplay').text(fluxQuery);
                    
                    const jsonText = JSON.stringify(request, null, 2);
                    $('#jsonDisplay').text(jsonText);
                    
                    $('#requestBody').val(jsonText);
                    $('#apiUrl').val('/api/query');
                },
                error: function(xhr, status, error) {
                    alert('生成失败: ' + error);
                }
            });
        }
        
        function executeQuery() {
            const apiUrl = $('#apiUrl').val();
            const requestBody = $('#requestBody').val();
            
            if (!apiUrl) {
                alert('请输入接口地址');
                return;
            }
            
            let contentType = 'application/json';
            let data = requestBody;
            
            if (apiUrl === '/api/execute/flux' || apiUrl === '/api/execute/raw') {
                contentType = 'text/plain';
                const jsonData = JSON.parse(requestBody);
                const request = {
                    entity_id: jsonData.entity_id,
                    measurement: jsonData.measurement,
                    start_time: jsonData.start_time,
                    end_time: jsonData.end_time,
                    density: jsonData.density,
                    aggregation: jsonData.aggregation,
                    limit: jsonData.limit
                };
                
                $.ajax({
                    url: '/api/raw/flux',
                    type: 'POST',
                    contentType: 'application/json',
                    data: JSON.stringify(request),
                    success: function(fluxQuery) {
                        performExecute(apiUrl, 'text/plain', fluxQuery);
                    },
                    error: function(xhr, status, error) {
                        alert('生成 Flux 语句失败: ' + error);
                    }
                });
            } else {
                performExecute(apiUrl, contentType, data);
            }
        }
        
        function performExecute(apiUrl, contentType, data) {
            $.ajax({
                url: apiUrl,
                type: 'POST',
                contentType: contentType,
                data: data,
                success: function(response) {
                    $('#resultContainer').show();
                    $('#resultDisplay').text(JSON.stringify(response, null, 2));
                    
                    if (response.data && response.data.length > 0) {
                        displayTable(response.data);
                        $('#tableContainer').show();
                    } else {
                        $('#tableContainer').hide();
                    }
                },
                error: function(xhr, status, error) {
                    $('#resultContainer').show();
                    $('#resultDisplay').text('查询失败: ' + error + '\n\n响应内容:\n' + xhr.responseText);
                    $('#tableContainer').hide();
                }
            });
        }
        
        function displayTable(data) {
            const dataBody = $('#dataBody');
            dataBody.empty();
            
            data.forEach(function(point) {
                const row = $('<tr>');
                row.append('<td>' + point._time + '</td>');
                row.append('<td>' + point._value + '</td>');
                dataBody.append(row);
            });
        }
    </script>
</body>
</html>
