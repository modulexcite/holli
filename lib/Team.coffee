# teams class

share.Teams = class Teams
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
		@allTeams.find {"lead._id": leadId}

	memberTeams: (memberId) ->
		@allTeams.find {members: { $elemMatch: {_id: memberId}}}

	leadTeamMembers: (leadId) ->
		_(@leadTeams(leadId)).map((t)-> _.map(t.members, (m)-> m._id)).flatten().value()

	leadTeamsRequests: (leadId) ->
		@allRequests.find {memberRef: {$in: @leadTeamMembers(leadId)}, to: {$gt: new Date()} }

