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

		myMembers = _($scope.teams).map((t)-> _.map(t.members, (m)-> m._id)).flatten().value()
		myTeamRequests = $scope.$meteorCollection () -> share.Requests.find {memberRef: {$in: myMembers}, to: {$gt: new Date()} }

		for r in myTeamRequests
			r.member = share.Employees.findOne(r.memberRef)
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

	$scope.requestDuration = (request) ->
		fromMoment = moment(request.from.toISOString())
		toMoment = moment(request.to.toISOString())
		moment.duration(toMoment.diff(fromMoment)).days()

	$scope.acceptRequest = (request) ->
		console.log request
		request.state = "accepted"
		console.log "accept request #{request.name} from #{request.member.name}"
		updateEvents()
	
	$scope.denyRequest = (request) ->
		console.log request
		# TODO: give reason
		reason = "-"
		request.state = "denied"
		request.denyReason = reason
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
	$scope.member = share.Employees.findOne {name: "Olaf von Dühren"}
	console.log "member (lead): #{$scope.member}"
	$scope.teams = $scope.$meteorCollection () -> share.Teams.find {"lead._id": $scope.member._id}
	updateEvents()
]