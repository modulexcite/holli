_ = lodash

angular.module('app').controller 'teamLeadCtrl', ['$scope', '$rootScope', '$meteor', '$window', 'uiCalendarConfig', '$timeout', ($scope, $rootScope, $meteor, $window, uiCalendarConfig, $timeout) ->
	updateEvents = () ->
		console.log "updateEvents"
		$scope.pendingRequests = []
		$scope.acceptedRequests = []
		# empty arrays, without setting new reference
		pendingEvents.events.splice(0, pendingEvents.events.length)
		acceptedEvents.events.splice(0, acceptedEvents.events.length)

		myTeamRequests = _.map $scope.TeamUtils.leadTeamsRequests($scope.leadId), (r) -> angular.copy r
		for r in myTeamRequests
			# add full member object to request
			r.member = share.Employees.findOne(r.memberRef)
			# find teams of memeber and lead
			r.teamsOfLead = $scope.TeamUtils.findTeamsOfLeadAndMember $scope.leadId, r.memberRef
			# find members teams not of this lead
			memberTeams = $scope.TeamUtils.memberTeams r.memberRef
			r.otherTeams = _.reject memberTeams, (t) -> _.some(r.teamsOfLead, (tt) -> tt._id == t._id)
			# add request to lists
			if r.from
				event = $scope.RequestUtils.createCalendarEvent r

				# only show in pending list (todo list) for leads teams that are not already denied by any other teams
				if $scope.RequestUtils.isPending(r._id, r.teamsOfLead) and not $scope.RequestUtils.isDenied(r._id, memberTeams)
					$scope.pendingRequests.push r
					console.log "add #{r.name} to PENDING (lead teams)"

				# but show event in calendar, if pending in any team
				if $scope.RequestUtils.isPending(r._id, memberTeams)
					pendingEvents.events.push event
					console.log "add #{r.name} to PENDING (all teams)"

				if $scope.RequestUtils.isAccepted(r._id, memberTeams)
					$scope.acceptedRequests.push r
					acceptedEvents.events.push event
					console.log "add #{r.name} to ACCEPTED"

	$scope.requestDuration = (request) ->
		$scope.RequestUtils.requestDuration request

	$scope.acceptRequest = (request) ->
		$scope.RequestUtils.accept request._id, request.teamsOfLead
		updateEvents()

	$scope.denyRequest = (request) ->
		reason = $window.prompt "Why is this denied?"
		$scope.RequestUtils.deny request._id, request.teamsOfLead, reason
		updateEvents()

	pendingEvents =
		textColor: '#000'
		color: '#efefef'
		events: []
	acceptedEvents =
		textColor: '#000'
		color: '#B8E297'
		events: []
	$scope.requestEventSources = [pendingEvents, acceptedEvents]

	$scope.calendarConfig =
		calendar:
			height: 500
			editable: false
			header:
				left: 'title'
				center: ''
				right: 'today prev,next'

	$scope.TeamUtils = new share.TeamUtils($meteor)
	$scope.RequestUtils = new share.RequestUtils($meteor)
	$scope.member = share.Employees.findOne {user: $rootScope.currentUser.username}
	console.log "member (lead): #{$rootScope.currentUser.username}"
	console.log $scope.member
	console.log $rootScope.currentUser
	$scope.leadId = $scope.member._id

	$scope.myTeams = $scope.TeamUtils.leadTeams $scope.leadId
	updateEvents()
	$scope.maxPrio = 3
]
