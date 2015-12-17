# meteor accounts config
Accounts.ui.config
	passwordSignupFields: 'USERNAME_ONLY'

# angular
_ = lodash
app = angular.module 'app', ['angular-meteor', 'ui.router', 'ui.bootstrap', 'ui.calendar']

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
		.state 'all-teams',
			url: '/all-teams'
			templateUrl: 'client/jade/all-teams.html'
			controller: 'allTeamsCtrl'
			resolve: userResolve
		.state 'employees',
			url: '/employees'
			templateUrl: 'client/jade/employees.html'
			controller: 'employeesCtrl'
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
