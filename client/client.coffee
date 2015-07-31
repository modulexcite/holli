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

app.controller 'memberDashboardCtrl', ['$scope', '$meteor', '$window', ($scope, $meteor, $window) ->
	$scope.member = share.Employees.findOne {name: "Sebastian Krämer"}
	console.log "member: #{$scope.member}"
	$scope.teams =  $scope.$meteorCollection () -> share.Teams.find {members: { $elemMatch: {_id: $scope.member._id}}}
	$scope.requests =  $scope.$meteorCollection () -> share.Requests.find {memberRef: $scope.member._id, to: {$gt: new Date()} }
	console.log "requests:"
	console.log $scope.requests
	$scope.minDate = new Date()
	$scope.maxDate = new Date(2020, 12, 31)
	$scope.format = 'dd.MM.yyyy'
	$scope.maxPrio = 3
	$scope.vacationFrom = new Date(2015, 7, 2)
	$scope.vacationTo = new Date(2015, 7, 5)
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
		newRequest = 
			memberRef: $scope.member._id
			name: $scope.newRequestName
			from: $scope.vacationFrom
			to: $scope.vacationTo
			prio: $scope.prio
			state: "pending"
			type: "vacation"

		$scope.$meteorCollection(share.Requests).save(newRequest).then (inserts) ->
			id = _.first(inserts)._id
			console.log "inserted new request with id:#{id}"

		# reset entry fields
		$scope.newRequestName = ""
		$scope.vacationFrom = null
		$scope.vacationTo = null
		$scope.prio = null
]

app.controller 'teamLeadCtrl', ['$scope', '$meteor', '$window', 'uiCalendarConfig', '$timeout', ($scope, $meteor, $window, uiCalendarConfig, $timeout) ->
	pendingEvents = 
		color: '#efefef'
		events: []
	acceptedEvents = 
		textColor: '#000'
		color: '#B8E297'
		events: []
	$scope.requestEventSources = [pendingEvents, acceptedEvents]

	updateRequests = () ->
		$scope.requests = []
		# empty arrays, without setting new reference
		pendingEvents.events.splice(0, pendingEvents.events.length)
		acceptedEvents.events.splice(0, acceptedEvents.events.length)

		for t in $scope.teams
			console.log "found team: #{t}"
			for m in t.members
				e = share.Employees.findOne m._id
				console.log "found my team member: #{e.name}"
				for r in _.filter(requests, (v) -> v.memberRef == e._id)
					r.member = e
					$scope.requests.push r
					if r.from
						event = 
							id: r._id
							title: "#{r.name} (#{r.member.name})"
							start: r.from
							end: r.to
							allDay: true
						if r.state == "pending"
							pendingEvents.events.push event
						if r.state == "accepted"
							acceptedEvents.events.push event

	$scope.acceptRequest = (request) ->
		console.log request
		request.state = "accepted"
		console.log "accept request #{request.name} from #{request.member.name}"
		updateRequests()
	
	$scope.denyRequest = (request) ->
		console.log request
		# TODO: give reason
		reason = "-"
		request.state = "denied"
		request.denyReason = reason
		console.log "denied request #{request.name} from #{request.member.name} with reason: #{reason}"
		updateRequests()

	$scope.uiConfig = {
			calendar:{
				height: 500,
				editable: false,
				header:{
					left: 'title',
					center: '',
					right: 'today prev,next'
				},
			}
		};
	requests = $scope.$meteorCollection(share.Requests)
	$scope.member = share.Employees.findOne {name: "Olaf von Dühren"}
	console.log "member (lead): #{$scope.member}"
	$scope.teams = $scope.$meteorCollection( () -> share.Teams.find {"lead._id": $scope.member._id} )
	updateRequests()
]