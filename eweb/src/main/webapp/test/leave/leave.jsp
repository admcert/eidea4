<%--
  Created by 刘大磊.
  Date: 2017-05-12 13:36:48
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="/inc/taglib.jsp" %>
<html>
<head>
    <title><%--用户Session--%><eidea:label key="leave.title"/></title>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <%@include file="/inc/inc_ang_js_css.jsp" %>
    <%@include file="/common/common_header.jsp" %>
</head>
<body>
<div ng-app='myApp' ng-view class="content"></div>
<jsp:include page="/common/searchPage">
    <jsp:param name="uri" value="${uri}"/>
</jsp:include>
</body>
<script type="text/javascript">
    var app = angular.module('myApp', ['ngFileUpload','ngRoute', 'ui.bootstrap', 'jcs-autoValidate'])
            .config(['$routeProvider', function ($routeProvider) {
                $routeProvider
                        .when('/list', {templateUrl: '<c:url value="/test/leave/list.tpl.jsp"/>'})
                        .when('/edit', {templateUrl: '<c:url value="/test/leave/edit.tpl.jsp"/>'})
                        .otherwise({redirectTo: '/list'});
            }]);
    app.controller('listCtrl', function ($rootScope,$scope,$http,$window) {
        $scope.allList = [];
        $scope.modelList = [];
        $scope.delFlag = false;
        $scope.canDel=PrivilegeService.hasPrivilege('delete');
        $scope.canAdd=PrivilegeService.hasPrivilege('add');
        $http.get("<c:url value="/test/leave/list"/>")
        .success(function (response) {
        if (response.success) {
        $scope.updateList(response.data);
        }
        else {
        bootbox.alert(response.message);
        }

        });
        $scope.updateList = function (data) {
        $scope.allList = data;
        $scope.queryParams.totalRecords  = $scope.allList.length;
        $scope.modelList.length = 0;
        $scope.pageChanged();
        };
        $scope.pageChanged = function (delF) {
        var bgn = ($scope.queryParams.pageNo - 1) * $scope.queryParams.pageSize;
        var end = bgn +  $scope.queryParams.pageSize;
        $scope.modelList.length = 0;
        if (delF == null) {
        delF = false;
        }
        for (var i = bgn; i < end && i < $scope.allList.length; i++) {
        var item = $scope.allList[i];
        item.delFlag = delF;
        $scope.modelList.push(item);

        }
        }
        $scope.canDelete = function () {
        for (var i = 0; i < $scope.modelList.length; i++) {
        if ($scope.modelList[i].delFlag) {
        return true;
        }
        }
        return false;
        }
        $scope.selectAll = function () {
        $scope.pageChanged($scope.delFlag);
        }
        $scope.deleteRecord = function () {

        bootbox.confirm({
        message: "<eidea:message key="common.warn.confirm.deletion"/>",
        buttons: {
        confirm: {
        label: '<eidea:label key="common.button.yes"/>',
        className: 'btn-success'
        },
        cancel: {
        label: '<eidea:label key="common.button.no"/>',
        className: 'btn-danger'
        }
        },
        callback: function (result) {
        if (result) {
        var ids = [];
        for (var i = 0; i < $scope.modelList.length; i++) {
        if ($scope.modelList[i].delFlag) {
        ids.push($scope.modelList[i].id);
        }
        }
        $http.post("<c:url value="/test/leave/deletes"/>", ids).success(function (data) {
        if (data.success) {
        bootbox.alert("<eidea:message key="common.warn.deleted.success"/>");
        $scope.updateList(data.data);
        }
        else {
        bootbox.alert(data.message);
        }

        });
        }
        }
        });
        };
        //可现实分页item数量
        $scope.maxSize =${pagingSettingResult.pagingButtonSize};
        if ($rootScope.listQueryParams != null) {
        $rootScope.queryParams = $scope.listQueryParams;
        $rootScope.queryParams.init = true;
        }
        else {
        $scope.queryParams = {
        pageSize:${pagingSettingResult.perPageSize},//每页显示记录数
        pageNo: 1, //当前页
        totalRecords: 0,//记录数
        init: true
        };
        $rootScope.listQueryParams = $scope.queryParams;
        }
        $scope.pageChanged();

        buttonHeader.listInit($scope,$window);
    });
    app.controller('editCtrl', function ($routeParams,$scope, $http,$window,$timeout, Upload) {
        $("#bgnTime").datetimepicker({
            format: 'yyyy-mm-dd hh:ii:ss',
            language: 'zh-CN',
            autoclose: 1,
            todayBtn:  1,
            showMeridian: 1,
            clearBtn:true
        }).on("click",function(){
            if($scope.leavePo.endTime == null){
                $("#bgnTime").datetimepicker("setEndDate","2099-01-01 00:00:00");
            }else{
                $("#bgnTime").datetimepicker("setEndDate",formatLongDate($scope.leavePo.endTime,'yyyy-MM-dd HH:mm:ss'));
            }
        });
        $("#endTime").datetimepicker({
            format: 'yyyy-mm-dd hh:ii:ss',
            language: 'zh-CN',
            autoclose: 1,
            todayBtn:  1,
            showMeridian: 1,
            clearBtn:true
        }).on("click",function(){
            if($scope.leavePo.bgnTime == null){
                $("#endTime").datetimepicker("setStartDate","1900-01-01 00:00:00");
            }else{
                $("#endTime").datetimepicker("setStartDate",formatLongDate($scope.leavePo.bgnTime,'yyyy-MM-dd HH:mm:ss'));
            }
        });
        $scope.message = '';
        $scope.leavePo = {};
        $scope.canAdd=PrivilegeService.hasPrivilege('add');
        var url = "<c:url value="/test/leave/create"/>";
        if ($routeParams.id != null) {
            url = "<c:url value="/test/leave/get"/>" + "?id=" + $routeParams.id;
        }
        $http.get(url)
                .success(function (response) {
                    if (response.success) {
                        $scope.leavePo = response.data;
                        $scope.tableId=$scope.leavePo.id;
                        $scope.canSave=(PrivilegeService.hasPrivilege('add')&&$scope.leavePo.id==null)||PrivilegeService.hasPrivilege('update');
                    }
                    else {
                        bootbox.alert(response.message);
                    }
                }).error(function (response) {
            bootbox.alert(response);
        });
        $scope.save = function () {
            if ($scope.editForm.$valid) {
                var postUrl = '<c:url value="/test/leave/saveForUpdated"/>';
                if ($scope.leavePo.id == null) {
                    postUrl = '<c:url value="/test/leave/saveForCreated"/>';
                }
                $http.post(postUrl, $scope.leavePo).success(function (data) {
                    if (data.success) {
                        $scope.message = "<eidea:label key="base.save.success"/>";
                        $scope.leavePo = data.data;
                    }
                    else {
                        $scope.message = data.message;
                        $scope.errors=data.data;
                    }
                }).error(function (data, status, headers, config) {
                    alert(JSON.stringify(data));
                });
            }
        }
        $scope.submitApprove=function () {
            $http.post('<c:url value="/test/leave/saveForApprove/"/>', $scope.leavePo).success(function (data) {
                if (data.success) {
                    $scope.message = "<eidea:message key="leave.label.application.submit.success"/>";

                }
                else {
                    $scope.message = data.message;
                    $scope.errors=data.data;
                }
            }).error(function (data, status, headers, config) {
                alert(JSON.stringify(data));
            });
        };
        $scope.create = function () {
            $scope.message = "";
            $scope.leavePo = {};
            var url = "<c:url value="/test/leave/create"/>";
            $http.get(url)
                    .success(function (response) {
                        if (response.success) {
                            $scope.leavePo = response.data;
                            $scope.canSave=(PrivilegeService.hasPrivilege('add')&&$scope.leavePo.id==null)||PrivilegeService.hasPrivilege('update');
                        }
                        else {
                            bootbox.alert(response.message);
                        }
                    }).error(function (response) {
                bootbox.alert(response);
            });
        }

        buttonHeader.editInit($scope,$http,$window,$timeout, Upload,"/base");
    });
    app.run([
        'bootstrap3ElementModifier',
        function (bootstrap3ElementModifier) {
            bootstrap3ElementModifier.enableValidationStateIcons(true);
        }]);
</script>
</html>
