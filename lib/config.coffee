# do not let user create accounts
Accounts.config
	forbidClientAccountCreation: true

# create collections
share.Employees = new Mongo.Collection 'employees'
share.Teams = new Mongo.Collection 'teams'
share.Requests = new Mongo.Collection 'requests'

# add created, updated etc fields
share.Employees.attachBehaviour 'timestampable'
share.Teams.attachBehaviour 'timestampable'
share.Requests.attachBehaviour 'timestampable'

# user access config
allowOnlyLoginUsers = 
	insert: (userId) ->
		userId?
	update: (userId) ->
		userId?
	remove: (userId) ->
		userId?

share.Employees.allow allowOnlyLoginUsers
share.Teams.allow allowOnlyLoginUsers
share.Requests.allow allowOnlyLoginUsers
