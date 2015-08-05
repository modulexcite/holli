# request class
_ = lodash

share.RequestUtils = class RequestUtils
	constructor: (@angularMeteor) ->
		@allTeams = @angularMeteor.collection share.Teams
		@allRequests = @angularMeteor.collection share.Requests
		@allEmployees = @angularMeteor.collection share.Employees

	getRequest: (id) ->
		@angularMeteor.object share.Requests, id

	accept: (requestId, teams) ->
		@setResponse requestId, teams, 'accepted'

	deny: (requestId, teams) ->
		@setResponse requestId, teams, 'denied'

	setResponse: (requestId, teams, state) ->
		request = @getRequest requestId
		for t in teams
			_.set request.responses, "#{t._id}.state" , state
		request.save()
		console.log request
		console.log "#{state} request #{request.name} from #{request.memberRef}"

	isAccepted: (requestId, teams) ->
		r = @getRequest requestId
		_.every(teams, (t) -> r.responses[t._id]? && r.responses[t._id].state == 'accepted')

	isPending: (requestId, teams) ->
		#is this right??
		not @isDenied(requestId, teams) and not @isAccepted(requestId, teams)

	isDenied: (requestId, teams) ->
		r = @getRequest requestId
		_.some(teams, (t) -> r.responses[t._id]? && r.responses[t._id].state == 'denied')

	createCalendarEvent: (request) ->
		id: request._id
		title: "#{request.name} (#{request.member.name})"
		start: request.from
		end: request.to
		allDay: true

	createNewRequest: (memberId, name, from, to, prio) ->
		newRequest = 
			memberRef: memberId
			name: name
			from: from
			to: to
			prio: prio
			type: "vacation"
			responses: {}
		@allRequests.save(newRequest)