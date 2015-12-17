_ = lodash

angular.module('app').controller 'employeesCtrl', ['$scope', '$meteor', '$window', ($scope, $meteor, $window) ->

	$scope.employees = $scope.$meteorCollection(share.Employees)
	$scope.teamsOf = (employee) -> "-"
	$scope.teamsLeadOf = (employee) -> "-"
]
