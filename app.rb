class App < Sinatra::Base
	enable:sessions

	get '/' do
		slim(:index)
	end

	post '/register' do
		db = SQLite3::Database.new('iForumDB.sqlite')
		username = params[:username]
		nickname = params[:nickname]
		password1 = params[:password1]
		password2 = params[:password2]

		if password1 == password2
			exist = db.execute("SELECT * FROM users WHERE username =?",[username])
			if exist.empty? == false
				redirect '/error'
			end
			crypt = BCrypt::Password.create(password1)
			db.execute("INSERT INTO users('username','nickname','password','points','admin_user_id') VALUES(?,?,?,?,?)" , ["#{username}","#{nickname}","#{crypt}"],0,2)
			redirect '/'

		end


	end

	post '/login' do
		db = SQLite3::Database.new('iForumDB.sqlite')
		username = params[:username]
		password = params[:password]
		check = db.execute("SELECT password FROM users WHERE username=?",[username])
		p check
		crypt = BCrypt::Password.new(check[0][0])
		p crypt
		if crypt == password
			session[:user] = true
			nickname = db.execute("SELECT nickname FROM users WHERE username=?",[username])
			session[:nickname] = nickname[0][0]
			redirect '/'
		else
			redirect '/error'
		end

	end

	get '/logout' do
		session.destroy
		redirect '/'
	end

	get '/getadminpowers' do
		
	end



end           