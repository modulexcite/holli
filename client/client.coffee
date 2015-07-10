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
	$scope.employees = $meteor.collection(share.Employees)
	$scope.teams = $meteor.collection(share.Teams)
	if $scope.teams.length > 0
		$scope.currentTeam = $scope.teams[0]

	$scope.selectTeam = (team) ->
		console.log "select team: #{team.name}"
		for t in $scope.teams
			t.selected = false
		team.selected = true
		$scope.currentTeam = team
	
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

	$scope.addUndersigner = (newundersigner) ->
		console.log "add new undersigner: #{newundersigner.name}"
		if $scope.currentTeam
			$scope.currentTeam.undersigners.push newundersigner

	$scope.addMember = (newmember) ->
		console.log "add new member: #{newmember.name}"
		if $scope.currentTeam
			$scope.currentTeam.members.push newmember
]

app.controller 'memberDashboardCtrl', ['$scope', '$meteor', '$window', ($scope, $meteor, $window) ->
]
