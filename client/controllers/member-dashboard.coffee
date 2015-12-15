_ = lodash

angular.module('app').controller 'memberDashboardCtrl', ['$scope', '$rootScope', '$meteor', '$window', ($scope, $rootScope, $meteor, $window) ->
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
		savePromise = $scope.RequestUtils.createNewRequest $scope.member._id, $scope.newRequestName, $scope.vacationFrom, $scope.vacationTo, $scope.prio
		savePromise.then (inserts) ->
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
			r.memberTeams = $scope.TeamUtils.memberTeams r.member._id
			if r.from
				event =
					id: r._id
					title: "#{r.name} (#{r.member.name})"
					start: r.from
					end: r.to
					allDay: true

				if $scope.RequestUtils.isDenied(r._id, r.memberTeams)
					r.denyReasons = $scope.RequestUtils.getDenyReasons r
					$scope.deniedRequests.push r
					console.log "add #{r.name} to DENIED"

				else if $scope.RequestUtils.isAccepted(r._id, r.memberTeams)
					acceptedEvents.events.push event
					$scope.acceptedRequests.push r
					console.log "add #{r.name} to ACCEPTED"

				else
					pendingEvents.events.push event
					$scope.pendingRequests.push r
					console.log "add #{r.name} to PENDING"


	# ---------------------------------------------------------------------------------
	$scope.TeamUtils = new share.TeamUtils($meteor)
	$scope.RequestUtils = new share.RequestUtils($meteor)

	$scope.member = share.Employees.findOne {user: $rootScope.currentUser.username}
	console.log "member: #{$rootScope.currentUser.username}"
	console.log $rootScope.currentUser
	console.log $scope.member
	$scope.teams =  $scope.$meteorCollection () -> share.Teams.find {members: { $elemMatch: {_id: $scope.member._id}}}
	$scope.requests =  $scope.$meteorCollection () -> share.Requests.find {memberRef: $scope.member._id, to: {$gt: new Date()} }
	allRequests = $scope.$meteorCollection(share.Requests)
	$scope.minDate = new Date()
	$scope.maxDate = new Date(2020, 12, 31)
	$scope.format = 'dd.MM.yyyy'
	$scope.maxPrio = 3
	$scope.vacationFrom = new Date(2015, 7, 10)
	$scope.vacationTo = new Date(2015, 7, 20)
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
	$scope.calendarConfig =
		calendar:
			height: 500
			editable: false
			header:
				left: 'title'
				center: ''
				right: 'today prev,next'
	updateEvents()
]
