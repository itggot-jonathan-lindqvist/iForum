class App < Sinatra::Base
	enable:sessions

	get '/' do
		db = SQLite3::Database.new('iForumDB.sqlite')
		min = 1
		max = db.execute("SELECT COUNT(*) FROM posts")
		rand_post = rand(min...max)
		print rand_post
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
		session[:username] = username
		check = db.execute("SELECT password FROM users WHERE username=?",[username])
		p check
		crypt = BCrypt::Password.new(check[0][0])
		p crypt
		if crypt == password
			session[:user] = true
			nickname = db.execute("SELECT nickname FROM users WHERE username=?",[username])
			session[:nickname] = nickname[0][0]
			points = db.execute("SELECT points FROM users WHERE username=?",[username])
			session[:points] = points[0][0]
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
		if session[:user] == true
			slim(:getadminpowers)
		else
			redirect('/')
		end
	end

	post '/getadminpowers' do
		if params[:password] == "katter"
			session[:adminerror] = false
			username = params[:username]
			db = SQLite3::Database.new('iForumDB.sqlite')
			db.execute("UPDATE users SET admin_user_id = 1 WHERE username=?",[username])
			redirect('/')
		else 
			session[:adminerror] = true
			redirect('/getadminpowers')
		end

	end

	get '/post' do
		slim(:post)
	end

	post '/post' do
		db = SQLite3::Database.new('iForumDB.sqlite')
		content = params[:content]
		title = params[:title]
		cat = params[:cat]
		cat_id = db.execute("SELECT id FROM category WHERE name=?",[cat])
		user_id = db.execute("SELECT id FROM users WHERE username=?",[session[:username]])
		db.execute("INSERT INTO posts(user_id, points, content, Title, cat_id) VALUES(?,?,?,?,?)",[user_id, 0, content, title, cat_id])
		redirect '/'
	end

	get '/myprofile' do 
		if session[:user] == false
			redirect('/')
		else
			db = SQLite3::Database.new('iForumDB.sqlite')
			username = session[:username]
			info = db.execute("SELECT * FROM users WHERE username=?",[username])
			info = info[0]
			username = info[1]
			nickname = info[2]
			password = info[3]
			points = info[4]
			
			slim(:myprofile, locals:{ username:username, nickname:nickname, points:points} )
		end
	end

end           
