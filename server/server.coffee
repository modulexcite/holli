Meteor.startup () ->
	# create default users
	stdUser = Meteor.users.findOne({username: "olaf"})
	if !stdUser
		Accounts.createUser
			username: "olaf"
			password: "olaf"
	stdUser = Meteor.users.findOne({username: "rafi"})
	if !stdUser
		Accounts.createUser
			username: "rafi"
			password: "rafi"


	# not used, was for init...
	if share.Employees.find().count() == 0
		fs = Npm.require 'fs'
		path = Npm.require 'path'
		basepath = path.resolve('.').split('.meteor')[0]
		file = basepath + "server/gb20.json"
		data_raw = fs.readFileSync file, 'utf8'
		data = JSON.parse data_raw
		for e in data
			share.Employees.insert 
				name: e.Name
				gb: 20
				active: true
				vacations: []
