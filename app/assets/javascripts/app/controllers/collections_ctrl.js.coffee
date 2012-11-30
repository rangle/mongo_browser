@CollectionsCtrl = ($scope, $element, $http, tableFilterFactory, confirmationDialog, doAction) ->
  dbName = $element.data("db-name")

  $scope.loading = true
  $http.get("/databases/#{dbName}.json").success (data) ->
    $scope.collections = data
    $scope.tableFilter = tableFilterFactory($scope, "collections")

    $scope.$on "FilterChange", (event, value) ->
      $scope.tableFilter.filter(value)

    $scope.loading = false

  $scope.isLoading = -> $scope.loading

  $scope.delete = (collection) ->
    confirmationDialog
      message: "Deleting #{collection.name}. Are you sure?"
      onOk: ->
        url = "/databases/#{dbName}/collections/#{collection.name}"
        doAction(url, "delete")