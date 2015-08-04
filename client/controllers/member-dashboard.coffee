_ = lodash

angular.module('app').controller 'memberDashboardCtrl', ['$scope', '$meteor', '$window', ($scope, $meteor, $window) ->
	
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

	$scope.deleteRequest = (request) ->
		console.log "remove request: #{request.name}"
		$scope.$meteorCollection(share.Requests).remove request
		updateEvents()

	$scope.createRequest = () ->
		newRequest = 
			memberRef: $scope.member._id
			name: $scope.newRequestName
			from: $scope.vacationFrom
			to: $scope.vacationTo
			prio: $scope.prio
			type: "vacation"
			responses: {}

		$scope.$meteorCollection(share.Requests).save(newRequest).then (inserts) ->
			id = _.first(inserts)._id
			console.log "inserted new request with id:#{id}"
			# reset entry fields
			$scope.newRequestName = ""
			#$scope.vacationFrom = null
			#$scope.vacationTo = null
			$scope.prio = null
			updateEvents()
		

	updateEvents = () ->
		# empty arrays, without setting new reference
		pendingEvents.events.splice(0, pendingEvents.events.length)
		acceptedEvents.events.splice(0, acceptedEvents.events.length)
		$scope.pendingRequests = []
		$scope.acceptedRequests = []
		$scope.deniedRequests = []

		for r in _.filter(allRequests, (v) -> v.memberRef == $scope.member._id)
			r.member = share.Employees.findOne(r.memberRef)
			if r.from
				event = 
					id: r._id
					title: "#{r.name} (#{r.member.name})"
					start: r.from
					end: r.to
					allDay: true

				console.log r
				# only one denied is enough to let a request fail
				if _.some(r.teamsOfLead, (t) -> r.responses[t._id]? && r.responses[t._id].state == 'denied')
					$scope.deniedRequests.push r
					console.log "add #{r.name} to DENIED"
				# all must be accepted to accept  request
				else if _.every(r.teamsOfLead, (t) -> r.responses[t._id]? && r.responses[t._id].state == 'accepted')
					acceptedEvents.events.push event
					$scope.acceptedRequests.push r
					console.log "add #{r.name} to ACCEPTED"
				# all other should be pending...right?
				else 
					pendingEvents.events.push event
					$scope.pendingRequests.push r
					console.log "add #{r.name} to PENDING"

	# ---------------------------------------------------------------------------------
	$scope.member = share.Employees.findOne {name: "Sebastian Krämer"}
	console.log "member: #{$scope.member}"
	$scope.teams =  $scope.$meteorCollection () -> share.Teams.find {members: { $elemMatch: {_id: $scope.member._id}}}
	$scope.requests =  $scope.$meteorCollection () -> share.Requests.find {memberRef: $scope.member._id, to: {$gt: new Date()} }
	allRequests = $scope.$meteorCollection(share.Requests)
	$scope.minDate = new Date()
	$scope.maxDate = new Date(2020, 12, 31)
	$scope.format = 'dd.MM.yyyy'
	$scope.maxPrio = 3
	$scope.vacationFrom = new Date(2015, 7, 2)
	$scope.vacationTo = new Date(2015, 7, 5)
	$scope.dateOptions =
		formatYear: 'yy'
		startingDay: 1
	pendingEvents = 
		textColor: '#000'
		color: '#efefef'
		events: []
	acceptedEvents = 
		textColor: '#000'
		color: '#B8E297'
		events: []
	$scope.requestEventSources = [pendingEvents, acceptedEvents]
	$scope.uiConfig =
		calendar:
			height: 500
			editable: false
			header:
				left: 'title'
				center: ''
				right: 'today prev,next'
	updateEvents()
]
