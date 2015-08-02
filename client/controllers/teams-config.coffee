_ = lodash

angular.module('app').controller 'teamsConfigCtrl', ['$scope', '$meteor', '$window', ($scope, $meteor, $window) ->
	$scope.selectTeam = (team) ->
		console.log "select team: #{team.name}"
		for t in $scope.teams
			t.selected = false
		team.selected = true
		$scope.currentTeam = team

	registerWatch = () ->
		$scope.watchTeamName = $scope.$watch 'newteamname', ((newValue, oldValue) ->
				if not _.isEqual oldValue, newValue
					# check for name existence
					f = _.some $scope.teams, (t) -> t.name == newValue
					$scope.teamNameNotUnique = f
			), true

	$scope.deleteTeam = (team) ->
		if $window.confirm 'Wirklich löschen?'
			console.log "delete team id: #{team._id}"
			$scope.teams.remove team

	$scope.createTeam = (teamname, teamlead) ->
		$scope.$meteorCollection(share.Teams).save
			name: teamname
			lead: 
				_id: teamlead._id
				name: teamlead.name
			undersigners: []
			members: []
		$scope.newteamname = ""

	$scope.addMember = (newmember) ->
		console.log "add new member: #{newmember.name}"
		if $scope.currentTeam
			$scope.currentTeam.members.push 
				_id: newmember._id
				name: newmember.name
		$scope.newMember = null

	$scope.removeMember = (member) ->
		console.log "remove member: #{member.name}"
		if $scope.currentTeam
			_.remove $scope.currentTeam.members, member

	$scope.employees = $scope.$meteorCollection(share.Employees)
	$scope.teams = $scope.$meteorCollection(share.Teams)
	console.log $scope.teams
	if $scope.teams.length > 0
		$scope.selectTeam($scope.teams[0])
	registerWatch()
]
