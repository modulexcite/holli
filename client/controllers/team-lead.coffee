_ = lodash

angular.module('app').controller 'teamLeadCtrl', ['$scope', '$meteor', '$window', 'uiCalendarConfig', '$timeout', ($scope, $meteor, $window, uiCalendarConfig, $timeout) ->
	updateEvents = () ->
		$scope.requests = []
		# empty arrays, without setting new reference
		pendingEvents.events.splice(0, pendingEvents.events.length)
		acceptedEvents.events.splice(0, acceptedEvents.events.length)

		myTeamRequests = $scope.Teams.leadTeamsRequests $scope.member._id

		for r in myTeamRequests
			# add full member object to request
			r.member = share.Employees.findOne(r.memberRef)
			# find teams of memeber and lead
			r.teamsOfLead = $scope.Teams.findTeamsOfLeadAndMember $scope.member._id, r.member._id
			# find members teams not of this lead
			memberTeams = $scope.Teams.memberTeams r.member._id
			r.otherTeams = _.reject memberTeams, (t) -> _.some(r.teamsOfLead, (tt) -> tt._id == t._id)
			# add request to lists
			if r.from
				event = $scope.Requests.createCalendarEvent r

				if $scope.Requests.isPending(r._id, r.teamsOfLead)
					$scope.requests.push r
					pendingEvents.events.push event
				
				if $scope.Requests.isAccepted(r._id, r.teamsOfLead)
					acceptedEvents.events.push event

	$scope.requestDuration = (request) ->
		# FIXME, count only workdays
		fromMoment = moment(request.from.toISOString())
		toMoment = moment(request.to.toISOString())
		moment.duration(toMoment.diff(fromMoment)).days()

	$scope.acceptRequest = (request) ->
		$scope.Requests.accept request._id, request.teamsOfLead
		updateEvents()
	
	$scope.denyRequest = (requestUI) ->
		$scope.Requests.deny request._id, request.teamsOfLead
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

	$scope.Teams = new share.Teams($meteor)
	$scope.Requests = new share.Requests($meteor)
	requests = $scope.$meteorCollection(share.Requests)
	if Meteor.user().username == 'olaf'
		$scope.member = share.Employees.findOne {name: "Olaf von Dühren"}
	else
		$scope.member = share.Employees.findOne {name: "Rafael Velásquez"}
	console.log "member (lead): #{$scope.member.name}"

	$scope.myTeams = $scope.Teams.leadTeams $scope.member._id
	updateEvents()
	$scope.maxPrio = 3
]