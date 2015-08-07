_ = lodash

angular.module('app').controller 'allTeamsCtrl', ['$scope', '$meteor', '$window', ($scope, $meteor, $window) ->

	registerWatch = () ->
		$scope.watchTeamName = $scope.$watch 'search', ((newValue, oldValue) ->
				if not _.isEqual oldValue, newValue
					# check for name existence
					updateEvents()
			), true
	
	matches = (text) -> 
		if text?
			r = new RegExp $scope.search
			text.match r
		else
			false

	updateEvents = () ->
		# empty arrays, without setting new reference
		pendingEvents.events.splice(0, pendingEvents.events.length)
		acceptedEvents.events.splice(0, acceptedEvents.events.length)
		$scope.pendingRequests = []
		$scope.acceptedRequests = []
		$scope.deniedRequests = []

		for r in $scope.requests
			r.member = share.Employees.findOne(r.memberRef)
			if matches(r.name) or matches(r.member.name)
				r.memberTeams = $scope.TeamUtils.memberTeams r.member._id
				if r.from
					event = 
						id: r._id
						title: "#{r.name} (#{r.member.name})"
						start: r.from
						end: r.to
						allDay: true

					if $scope.RequestUtils.isAccepted(r._id, r.memberTeams)
						acceptedEvents.events.push event
						console.log "add #{r.name} to ACCEPTED"
					
					else
						pendingEvents.events.push event
						console.log "add #{r.name} to PENDING"
					

	# ---------------------------------------------------------------------------------
	$scope.TeamUtils = new share.TeamUtils($meteor)
	$scope.RequestUtils = new share.RequestUtils($meteor)

	$scope.requests =  $scope.$meteorCollection () -> share.Requests.find { to: {$gt: new Date()} }
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
	updateEvents()
	registerWatch()
]
