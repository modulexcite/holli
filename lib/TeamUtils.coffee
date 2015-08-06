# teams class
_ = lodash

share.TeamUtils = class TeamUtils
	constructor: (@angularMeteor) ->

	# return all memebers of temas given by their id
	membersOfTeams: (teamIds) ->
		members = []
		for tid in teamIds
			t = share.Teams.findOne tid
			for m in t?.members
				members.push m
		members

	# search shared teams of a team-lead and a member, return full team records
	findTeamsOfLeadAndMember: (leadId, memberId) ->
		_.filter(@leadTeams(leadId), (t) -> if t.members? then _.some(t.members, (m) -> m._id == memberId))

	# search teams of a lead, return full team records
	leadTeams: (leadId) ->
		@angularMeteor.collection () -> share.Teams.find {"lead._id": leadId}

	# search teams of a member, return full team records
	memberTeams: (memberId) ->
		@angularMeteor.collection () -> share.Teams.find {members: { $elemMatch: {_id: memberId}}}

	# search for lead teams and return ids of their members		
	leadTeamMembers: (leadId) ->
		_(@leadTeams(leadId)).map((t)-> _.map(t.members, (m)-> m._id)).flatten().value()

	# search all request of leads teams members
	leadTeamsRequests: (leadId) ->
		ltm = @leadTeamMembers(leadId)
		@angularMeteor.collection () -> share.Requests.find {memberRef: {$in: ltm}, to: {$gt: new Date()} }