_ = lodash

angular.module('app').controller 'teamLeadCtrl', ['$scope', '$meteor', '$window', 'uiCalendarConfig', '$timeout', ($scope, $meteor, $window, uiCalendarConfig, $timeout) ->
	pendingEvents = 
		textColor: '#000'
		color: '#efefef'
		events: []
	acceptedEvents = 
		textColor: '#000'
		color: '#B8E297'
		events: []
	$scope.requestEventSources = [pendingEvents, acceptedEvents]

	updateEvents = () ->
		$scope.requests = []
		# empty arrays, without setting new reference
		pendingEvents.events.splice(0, pendingEvents.events.length)
		acceptedEvents.events.splice(0, acceptedEvents.events.length)

		myMembers = _($scope.myTeams).map((t)-> _.map(t.members, (m)-> m._id)).flatten().value()
		myTeamRequests = $scope.$meteorCollection () -> share.Requests.find {memberRef: {$in: myMembers}, to: {$gt: new Date()} }

		for r in myTeamRequests
			# add full member object to request
			r.member = share.Employees.findOne(r.memberRef)
			# find teams of memeber and lead
			r.teamsOfLead = findTeamsOfLeadAndMember($scope.member._id, r.memberRef)
			# find members teams not of this lead
			memberTeams = $scope.$meteorCollection () -> share.Teams.find {members: { $elemMatch: {_id: r.memberRef}}}
			r.otherTeams = _.reject memberTeams, (t) -> _.some(r.teamsOfLead, (tt) -> tt._id == t._id)
			# add request to lists
			if r.from
				event = 
					id: r._id
					title: "#{r.name} (#{r.member.name})"
					start: r.from
					end: r.to
					allDay: true
				if _.every(r.teamsOfLead, (t) -> r.responses[t._id]? && r.responses[t._id].state == 'pending')
					$scope.requests.push r
					pendingEvents.events.push event
				if _.every(r.teamsOfLead, (t) -> r.responses[t._id]? && r.responses[t._id].state == 'accepted')
					acceptedEvents.events.push event

	$scope.requestDuration = (request) ->
		# FIXME, count only workdays
		fromMoment = moment(request.from.toISOString())
		toMoment = moment(request.to.toISOString())
		moment.duration(toMoment.diff(fromMoment)).days()

	findTeamsOfLeadAndMember = (leadId, memberId) ->
		myTeams = $scope.$meteorCollection () -> share.Teams.find {"lead._id": leadId}
		_.filter(myTeams, (t) -> if t.members? then _.some(t.members, (m) -> m._id == memberId))

	$scope.acceptRequest = (requestUI) ->
		console.log request
		request = $scope.$meteorObject(share.Requests, requestUI._id)
		for t in request.teamsOfLead
			r = request.responses[t._id] || {}
			r.state = "accepted"
		console.log "accept request #{request.name} from #{request.member.name}"
		updateEvents()
	
	$scope.denyRequest = (requestUI) ->
		console.log request
		request = $scope.$meteorObject(share.Requests, requestUI._id)
		# TODO: give reason
		reason = "-"
		for t in request.teamsOfLead
			r = request.responses[t._id] || {}
			r.state = "accepted"
			r.denyReason = reason
		console.log "denied request #{request.name} from #{request.member.name} with reason: #{reason}"
		updateEvents()

	$scope.uiConfig =
		calendar:
			height: 500
			editable: false
			header:
				left: 'title'
				center: ''
				right: 'today prev,next'
	requests = $scope.$meteorCollection(share.Requests)
	if Meteor.user().username == 'olaf'
		$scope.member = share.Employees.findOne {name: "Olaf von Dühren"}
	else
		$scope.member = share.Employees.findOne {name: "Rafael Velásquez"}
	console.log "member (lead): #{$scope.member.name}"
	$scope.myTeams = $scope.$meteorCollection () -> share.Teams.find {"lead._id": $scope.member._id}
	updateEvents()
	$scope.maxPrio = 3
]