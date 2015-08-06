# request class
_ = lodash

share.RequestUtils = class RequestUtils
	constructor: (@angularMeteor) ->
		@allRequests = @angularMeteor.collection share.Requests

	# get full request record from id
	getRequest: (id) ->
		@angularMeteor.object share.Requests, id

	# set accepted for request for some teams
	accept: (requestId, teams) ->
		@setResponse requestId, teams, 'accepted'

	# set denied for request for some teams
	deny: (requestId, teams, reason) ->
		@setResponse requestId, teams, 'denied', reason

	# set 'state' for request for some teams
	setResponse: (requestId, teams, state, reason) ->
		request = @getRequest requestId
		for t in teams
			_.set request.responses, "#{t._id}.state" , state
			if reason
				_.set request.responses, "#{t._id}.reason" , reason
		console.log request
		request.save()
		console.log "#{state} request #{request.name} from #{request.memberRef}"

	# is request already accepted by all relevant teams?
	isAccepted: (requestId, teams) ->
		r = @getRequest requestId
		_.every(teams, (t) -> r.responses[t._id]? && r.responses[t._id].state == 'accepted')

	# is this request still pending in any team
	isPending: (requestId, teams) ->
		#is this right??
		not @isDenied(requestId, teams) and not @isAccepted(requestId, teams)

	# is this request denied by any team
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
		@allRequests.save newRequest

	getDenyReasons: (request) ->
		ret = []
		i = 0
		for k, v of request.responses
			if v.state == 'denied'
				t = share.Teams.findOne k
				ret.push {id: i++, reason: v.reason, team: t.name}
		ret