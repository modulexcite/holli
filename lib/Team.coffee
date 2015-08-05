# teams class
_ = lodash

share.TeamUtils = class TeamUtils
	constructor: (@angularMeteor) ->
		@allTeams = @angularMeteor.collection share.Teams
		@allRequests = @angularMeteor.collection share.Requests
		@allEmployees = @angularMeteor.collection share.Employees

	membersOfTeams: (teamIds) ->
		members = []
		for tid in teamIds
			t = @allTeams.findOne tid
			for m in t?.members
				members.push m
		members

	findTeamsOfLeadAndMember: (leadId, memberId) ->
		_.filter(@leadTeams(leadId), (t) -> if t.members? then _.some(t.members, (m) -> m._id == memberId))

	leadTeams: (leadId) ->
		@angularMeteor.collection () -> share.Teams.find {"lead._id": leadId}

	memberTeams: (memberId) ->
		@angularMeteor.collection () -> share.Teams.find {members: { $elemMatch: {_id: memberId}}}

	leadTeamMembers: (leadId) ->
		_(@leadTeams(leadId)).map((t)-> _.map(t.members, (m)-> m._id)).flatten().value()

	leadTeamsRequests: (leadId) ->
		ltm = @leadTeamMembers(leadId)
		console.log ltm
		@angularMeteor.collection () -> share.Requests.find {memberRef: {$in: ltm}, to: {$gt: new Date()} }