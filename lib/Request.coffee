# request class
_ = lodash

share.Requests = class Requests
	constructor: (@angularMeteor) ->
		@allTeams = @angularMeteor.collection share.Teams
		@allRequests = @angularMeteor.collection share.Requests
		@allEmployees = @angularMeteor.collection share.Employees

	getRequest: (id) ->
		$meteor.object share.Requests, id

	accept: (requestId, teamsOfLead) ->
		@setResponse requestId, teamsOfLead, 'accepted'

	deny: (requestId, teamsOfLead) ->
		@setResponse requestId, teamsOfLead, 'denied'

	setResponse: (requestId, teamsOfLead, state) ->
		for t in teamsOfLead
			r = request.responses[t._id] || {}
			r.state = state
		console.log "#{state} request #{request.name} from #{request.member.name}"

	isAccepted: (requestId, teamsOfLead) ->
		console.log "isAccepted:"
		r = @getRequest requestId
		console.log r
		_.every(teamsOfLead, (t) -> r.responses[t._id]? && r.responses[t._id].state == 'accepted')

	isPending: (requestId, teamsOfLead) ->
		#is this right??
		not isDenied and not isAccepted

	isDenied: (requestId) ->
		@getRequest requestId
		_.some(teamsOfLead, (t) -> r.responses[t._id]? && r.responses[t._id].state == 'denied')

	createCalendarEvent: (request) ->
		id: request._id
		title: "#{request.name} (#{request.member.name})"
		start: request.from
		end: request.to
		allDay: true
