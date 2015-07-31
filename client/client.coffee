# meteor accounts config
Accounts.ui.config
	passwordSignupFields: 'USERNAME_ONLY'

# angular
_ = lodash
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


	$scope.employees = $scope.$meteorCollection(share.Employees)
	$scope.teams = $scope.$meteorCollection(share.Teams)
	console.log $scope.teams
	if $scope.teams.length > 0
		$scope.selectTeam($scope.teams[0])

	registerWatch = () ->
		$scope.watchTeamName = $scope.$watch 'newteamname', ((newValue, oldValue) ->
				if not _.isEqual oldValue, newValue
					# check for name existence
					f = _.some $scope.teams, (t) -> t.name == newValue
					$scope.teamNameNotUnique = f
			), true

	registerWatch()

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
]

app.controller 'memberDashboardCtrl', ['$scope', '$meteor', '$window', ($scope, $meteor, $window) ->
	m = share.Employees.findOne {name: "Sebastian Krämer"}
	$scope.member = $scope.$meteorObject(share.Employees, m._id)
	console.log "member: #{$scope.member}"
	$scope.teams = _.filter($scope.$meteorCollection(share.Teams), (t) -> _.some(t.members, (m) -> m._id==$scope.member._id))
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
			_id: new Mongo.ObjectID()
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
	employees = $scope.$meteorCollection(share.Employees)
	$scope.member = share.Employees.findOne {name: "Olaf von Dühren"}
	console.log "member (lead): #{$scope.member}"
	$scope.teams = $scope.$meteorCollection( () -> share.Teams.find {"lead._id": $scope.member._id} )
	$scope.requests = []
	for t in $scope.teams
		console.log "found team: #{t}"
		for m in t.members
			e = share.Employees.findOne m._id
			console.log "found my team member: #{e.name}"
			for r in _.filter(e.vacations, (v) -> v.state == "pending")
				r.member = e
				$scope.requests.push r

	$scope.acceptRequest = (request) ->
		member = $scope.$meteorObject(share.Employees, request.member._id)
		console.log "accept request #{request.name} from #{request.member.name}"
		i = _.findIndex member.vacations, (req) -> req.name == request.name
		r = member.vacations[i]
		member.vacations[i].state = "accepted"
	
	$scope.denyRequest = (request) ->
		# TODO: give reason
		console.log "denied request #{request.name} from #{request.member.name} with reason: TODO"
		request.state = "denied"
]