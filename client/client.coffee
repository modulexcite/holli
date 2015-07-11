# meteor accounts config
Accounts.ui.config
	passwordSignupFields: 'USERNAME_ONLY'

# angular
app = angular.module 'app', ['angular-meteor', 'ui.router', 'ui.bootstrap']

# routes
userResolve = 
				"currentUser": [
					"$meteor", ($meteor) ->
						$meteor.requireUser()
				]

app.config ['$stateProvider', '$urlRouterProvider', '$locationProvider', ($stateProvider, $urlRouterProvider, $locationProvider) ->
	$stateProvider
		.state 'teams-config',
			url: '/teams-config'
			templateUrl: 'client/jade/teams-config.html'
			controller: 'teamsConfigCtrl'
			resolve: userResolve
		.state 'member-dashboard',
			url: '/member-dashboard'
			templateUrl: 'client/jade/member-dashboard.html'
			controller: 'memberDashboardCtrl'
			resolve: userResolve
		.state 'team-lead',
			url: '/team-lead'
			templateUrl: 'client/jade/team-lead.html'
			controller: 'teamLeadCtrl'
			resolve: userResolve
		.state 'login',
			url: '/login'
			templateUrl: 'client/jade/login.html'
			
	$urlRouterProvider.otherwise '/teams-config'
	$locationProvider.html5Mode true
]

app.run ['$rootScope', '$state', ($rootScope, $state) ->
	Accounts.onLogin () -> $state.go 'member-dashboard'
	accountsUIBootstrap3.logoutCallback = () -> $state.go 'login'
	$rootScope.$on '$stateChangeError', (event, toState, toParams, fromState, fromParams, error) ->
		# We can catch the error thrown when the $requireUser promise is rejected
		# and redirect the user back to the main page
		if error == 'AUTH_REQUIRED'
			$state.go 'login'
]

app.controller 'teamsConfigCtrl', ['$scope', '$meteor', '$window', ($scope, $meteor, $window) ->
	$scope.selectTeam = (team) ->
		console.log "select team: #{team.name}"
		for t in $scope.teams
			t.selected = false
		team.selected = true
		$scope.currentTeam = team


	$scope.employees = $meteor.collection(share.Employees)
	$scope.teams = $meteor.collection(share.Teams)
	if $scope.teams.length > 0
		$scope.selectTeam($scope.teams[0])

	
	$scope.deleteTeam = (team) ->
		if $window.confirm 'Wirklich löschen?'
			console.log "archive id: #{family._id}"

	$scope.createTeam = (teamname, teamlead) ->
		$meteor.collection(share.Teams).save
			name: teamname
			lead: 
				_id: teamlead._id
				name: teamlead.name
			undersigners: []
			members: []

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
			_remove $scope.currentTeam.members, member
]

app.controller 'memberDashboardCtrl', ['$scope', '$meteor', '$window', ($scope, $meteor, $window) ->
	$scope.member = _.find $meteor.collection(share.Employees), (e) -> e.name == "Sebastian Krämer"
	$scope.teams = _.filter($meteor.collection(share.Teams), (t) -> _.some(t.members, (m) -> m._id==$scope.member._id))
	$scope.minDate = new Date()
	$scope.maxDate = new Date(2020, 12, 31)
	$scope.format = 'dd.MM.yyyy'
	$scope.maxPrio = 3
	$scope.dateOptions =
		formatYear: 'yy'
		startingDay: 1

	$scope.hoveringOver = (value) ->
		$scope.overStar = value

	$scope.openFrom = ($event) ->
		$event.preventDefault()
		$event.stopPropagation()
		$scope.openedFrom = true

	$scope.openTo = ($event) ->
		$event.preventDefault()
		$event.stopPropagation()
		$scope.openedTo = true

	$scope.createRequest = () ->
		$scope.member.vacations.push
			name: $scope.newRequestName
			from: $scope.vacationFrom
			to: $scope.vacationTo
			prio: $scope.prio
			state: "pending"
		$scope.newRequestName = ""
		$scope.vacationFrom = null
		$scope.vacationTo = null
		$scope.prio = null
]

app.controller 'teamLeadCtrl', ['$scope', '$meteor', '$window', ($scope, $meteor, $window) ->
	employees = $meteor.collection(share.Employees)
	$scope.member = _.find employees, (e) -> e.name == "Olaf von Dühren"
	$scope.teams = _.filter($meteor.collection(share.Teams), (t) -> t.lead._id == $scope.member._id)
	$scope.requests = []
	for t in $scope.teams
		for m in t.members
			e = _.find employees, (e) -> e._id == m._id
			console.log "found my team member: #{e.name}"
			for r in _.filter(e.vacations, (v) -> v.state == "pending")
				r.member = e
				$scope.requests.push r
]