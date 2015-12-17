Meteor.startup () ->
	# init data
	fs = Npm.require 'fs'
	path = Npm.require 'path'
	basepath = path.resolve('.').split('.meteor')[0]
	file = basepath + "server/gb20.json"
	data_raw = fs.readFileSync file, 'utf8'
	data = JSON.parse data_raw
	for e in data
		username = e['user'].toLowerCase()
		if !share.Employees.findOne {user: username}
			share.Employees.insert
				name: e['name']
				user: username
				gb: 20
				active: true
				vacations: []
			Accounts.createUser
				username: username
				password: e['user'].toLowerCase()
				email: "#{e['user']}@inform-software.com"
