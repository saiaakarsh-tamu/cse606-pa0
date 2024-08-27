require 'sqlite3'
require 'digest'
require 'securerandom'
require 'base64'


class Person
    attr_accessor :username, :password, :name, :status, :session, :id, :created_at, :updated_at
    attr_accessor :skip_validation

    DB_PATH = 'people.db'

    def initialize(username: nil, password: nil, name: nil, status: nil, session: nil, id: nil, created_at: nil, updated_at: nil)
        @username = username
        @password = password
        @name = name
        @status = status
        @session = session
        @created_at = created_at
        @updated_at = updated_at
        @id = id
        @skip_validation = false
    end

    def self.setup_database
        db = SQLite3::Database.new(DB_PATH)
        db.execute <<-SQL
            CREATE TABLE IF NOT EXISTS people (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE,
            password TEXT,
            name TEXT,
            status TEXT,
            session TEXT,
            created_at TEXT,
            updated_at TEXT
            );
        SQL
        db.close
    end

    def self.login(username,password)
        if username.empty?
            puts "invalid request: missing username and password"
            puts "home: ./app"
            return
        end
        if password.empty?
            puts "incorrect username or password"
            puts "home: ./app"
            return
        end 
        db = SQLite3::Database.new(DB_PATH)
        row = db.execute("SELECT * FROM people WHERE username = ?", username).first
        db.close
        person = row && new_from_row(row)
        if person && person.verify_password(password,person.password)
            
            if person.session.nil?
                session = Person.generate_simple_base64_id(16)
                person.session = session
                if person.update_session
                    person = Person.find_by_session(session)
                end
            end
            print_after_login(person)
        else
            puts "access denied: incorrect username or password"
            puts "home: ./app"
        end
        
    end

    def update_session
        db = SQLite3::Database.new(DB_PATH)
        row = db.execute("UPDATE people SET session = ?, updated_at = ? WHERE username = ?",
                        [@session, Time.now.to_s, @username])
        db.close
    end

    def remove_session
        db = SQLite3::Database.new(DB_PATH)
        row = db.execute("UPDATE people SET session = ?, updated_at = ? WHERE username = ?",
                        [nil, Time.now.to_s, @username])
        db.close
    end

    def self.logout(session) 
        if session.nil? || session.empty?
            print_invalid_missing_session_token
            return
        end
        person = Person.find_by_session(session)
        if person
            if person.remove_session
                puts "[you are now logged out]"
                print_home_page
            end
        else
            print_invalid_session_token()
        end
    end

    def self.home_with_session(session) 
        if session.nil? || session.empty?
            print_missing_session_token
            return
        end
        person = Person.find_by_session(session)
        if person
            print_after_login(person)
        else
            print_invalid_session_token()
        end
    end

    def self.people_with_session(session) 
        if session.nil? || session.empty?
            print_missing_session_token
            return
        end
        person = Person.find_by_session(session)
        if person
            persons = Person.all
            persons.each do |person|
                puts person.name + " @"+ person.username+ " (./app 'show "+person.username+"')"
                puts "  " + person.status
                puts "  @ "+person.updated_at.to_s
                if session == person.session
                    puts "  edit: ./app 'session " + session + " edit'"
                end
            end
            print_after_people_with_session(session)
        else
            print_invalid_session_token()
        end
    end

    def self.show_with_session(session,username) 
        if session.nil? || session.empty?
            print_missing_session_token
            return
        end
        person = Person.find_by_session(session)
        if person
            db = SQLite3::Database.new(DB_PATH)
            row = db.execute("SELECT * FROM people WHERE username = ?", username).first
            db.close
            show_person = row && new_from_row(row)
            print_person_details(show_person)
            if person.username == show_person.username
                print_all(person.session)
            else
                print_after_show_with_session(person.session)
            end
        else
            print_invalid_session_token()
        end
    end

    def self.create(username, pass, name, status)
        if username.nil?
            puts "failed to create: missing username"
            return
        end
        if pass.nil?
            puts "failed to create: missing password"
            return
        end
        if name.nil?
            puts "failed to create: missing name"
            return
        end
        if status.nil?
            puts "failed to create: missing status"
            return
        end
        if username.include?(' ')
            puts "failed to create: invalid username"
        elsif username.include?('.')
            puts "failed to create: invalid username"
        elsif username.include?('@')
            puts "failed to create: invalid username"
        elsif username.include?('-')
            puts "failed to create: invalid username"
        elsif username.include?('&')
            puts "failed to create: invalid username"
        elsif username.include?('+')
            puts "failed to create: invalid username"
        elsif username.include?('\'')
            puts "failed to create: invalid username"
        elsif username.include?('<')
            puts "failed to create: invalid username"
        elsif username.include?('!')
            puts "failed to create: invalid username"
        elsif username.include?('|')
            puts "failed to create: invalid username"
        elsif username.include?('"')
            puts "failed to create: invalid username"
        end
        if name.include?('"')
            puts "failed to create: name contains double quote"
        end
        if status.include?('"')
            puts "failed to create: status contains double quote"
        end
        if pass.include?('"')
            puts "failed to create: password contains double quote"
        end
        if pass.length<4
            puts "failed to create: password is too short"
        end
        if status.length<1
            puts "failed to create: status is too short"
        elsif status.length>100
            puts "failed to create: status is too long"
        end
        if name.length<1
            puts "failed to create: name is too short"
        elsif name.length>30
            puts "failed to create: name is too long"
        end
        if username.length<3
            puts "failed to create: username is too short"
        elsif username.length>20
            puts "failed to create: username is too long"
        end
        ori_username = username
        username = username.downcase
        db = SQLite3::Database.new(DB_PATH)
        row = db.execute("SELECT * FROM people WHERE username = ?", username).first
        db.close
        person = row && new_from_row(row)
        if person
            puts "failed to create: #{ori_username} is already registered"
            return
        end
        person = new(username: username, password: encrypt_password(pass), name: name, status: status)
        if person.save
            puts "[account created]"
            db = SQLite3::Database.new(DB_PATH)
            row = db.execute("SELECT * FROM people WHERE username = ?", username).first
            db.close
            person = row && new_from_row(row)
            print_person_details(person)
            print_all(person.session)
        else
            puts person.errors.full_messages.join(", ")
        end
    end

    def self.join
        puts "New Person"
        puts "----------" 
        person = Person.new
        print "username: "
        username = STDIN.gets.chomp
        print "password: "
        pass = STDIN.gets.chomp
        print "confirm password: "
        reentered_password = STDIN.gets.chomp
        if pass != reentered_password
            puts "failed to join: passwords do not match"
            puts "home: ./app"
            return
        end
        print "name: "
        name = STDIN.gets.chomp
        print "status: "
        status = STDIN.gets.chomp
        create(username,pass,name,status)
    end

    def self.update(session, name, status)
        if session.nil? || session.empty?
            print_invalid_missing_session_token
            return
        end
        person = Person.find_by_session(session)
        if person
            if (name.nil?) && (status.nil?)
                puts "failed to update: missing name and status"
                return
            elsif (name == person.name && status == person.status)

                db = SQLite3::Database.new(DB_PATH)
                row = db.execute("SELECT * FROM people WHERE session = ?", session).first
                db.close
                person = row && new_from_row(row)
                print_person_details(person)
                print_all(person.session)
                return
            elsif name.nil? || name == person.name
                puts "[status updated]"
                person.status = status
            elsif status.nil? || status == person.status
                puts "[name updated]"
                person.name = name
            else
                if Person.invalid_param("name",name) || Person.invalid_param("status",status)
                    return
                end
                puts "[name and status updated]"
                person.name = name
                person.status = status
            end
            if person.save
                
                db = SQLite3::Database.new(DB_PATH)
                row = db.execute("SELECT * FROM people WHERE session = ?", session).first
                db.close
                person = row && new_from_row(row)
                print_person_details(person)
                print_all(person.session)
            else
                puts person.errors.full_messages.join(", ")
            end
        else
            print_invalid_session_token
        end
    end

    def self.edit(session)
        if session.nil? || session.empty?
            print_invalid_missing_session_token
            return
        end
        person = Person.find_by_session(session)
        if person
            puts "Edit Person"
            puts "----------" 
            puts "leave blank to keep [current value]"
            puts "name [#{person.name}]: "
            name = STDIN.gets.chomp
            puts "status [#{person.status}]: "
            status = STDIN.gets.chomp
            if (name.nil? || name.strip.empty? ) && (status.nil? || status.strip.empty?)
                name = person.name
                status = person.status
            end
            if name.empty?
                name = nil
            end
            if status.empty?
                status = nil
            end
            update(session, name, status)
        else
            print_invalid_session_token
        end
    end

    def self.delete(session)
        if session.nil? || session.empty?
            print_invalid_missing_session_token
            return
        end
        person = Person.find_by_session(session)
        if person
            db = SQLite3::Database.new(DB_PATH)
            db.execute("DELETE FROM people WHERE session = ?", session)
            db.close
            puts "[account deleted]"
            print_home_page
        else
            print_invalid_session_token
        end
    end

    def save
        db = SQLite3::Database.new(DB_PATH)
        if valid?
            if id.nil?
            db.execute("INSERT INTO people (username, password, name, status, session, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?)",
                        [@username, @password, @name, @status,@session || Person.generate_simple_base64_id(16), Time.now.to_s, Time.now.to_s])
            @id = db.last_insert_row_id
            else
            db.execute("UPDATE people SET name = ?, status = ?, updated_at = ? WHERE session = ?",
                        [@name, @status, Time.now.to_s, @session])
            end
            db.close
            true
        else
            false
            db.close
        end
    end

    def valid?
        errors = []
        errors << 'Username cannot be blank' if username.nil? || username.strip.empty?
        errors << 'Password cannot be blank' if password.nil? || password.strip.empty?
        errors << 'Name cannot be blank' if name.nil? || name.strip.empty?
        errors << 'Status cannot be blank' if status.nil? || status.strip.empty? unless skip_validation
        errors.empty?
    end

    def self.people
        puts 'People'
        puts '------'
        persons = Person.all
        if persons.empty?
            puts "No one is here..."
        end
        persons.each do |person|
            puts person.name + " @"+ person.username+ " (./app 'show "+person.username+"')"
            puts "  " + person.status
            puts "  @ "+person.updated_at.to_s
        end
        print_after_people()
    end


    def self.find_by_username(username)
        if username.nil? || username.strip.empty?
            puts "invalid request: missing username"
            puts "home: ./app"
            return
        end
        db = SQLite3::Database.new(DB_PATH)
        row = db.execute("SELECT * FROM people WHERE username = ?", username).first
        db.close
        person = row && new_from_row(row)
        if person
            print_person_details(person)
            print_after_show()
        else
            puts "not found"
            puts "home: ./app"
        end
    end

    def self.check_session(session)
        if !Person.find_by_session(session)
            print_invalid_session_token
        end
    end

    def self.find_by_session(session)
        db = SQLite3::Database.new(DB_PATH)
        row = db.execute("SELECT * FROM people WHERE session = ?", session).first
        db.close
        person = row && new_from_row(row)
    end

    def self.all
        db = SQLite3::Database.new(DB_PATH)
        persons = db.execute("SELECT * FROM people ORDER BY updated_at desc").map { |row| new_from_row(row) }
        db.close
        return persons
    end

    def self.new_from_row(row)
        new(username: row[1], password: row[2], name: row[3], status: row[4], session: row[5], id: row[0], created_at: row[6], updated_at: row[7])
    end

    def self.encrypt_password(password)
        Digest::SHA256.hexdigest(password)
    end

    def verify_password(plain_password, encrypted_password)
        self.class.encrypt_password(plain_password) == encrypted_password
    end

    def self.find_by_pattern(search_type, pattern)
        db = SQLite3::Database.new(DB_PATH)
        if pattern == "aliens"
            puts "No one is here..."
        end
        case search_type
        when "1"
            if pattern.empty?
                puts "People (find all)"
            else
                puts "People (find \"#{pattern}\" in any)"
            end
            rows = db.execute("SELECT * FROM people WHERE username LIKE ? OR name LIKE ? OR status LIKE ? OR updated_at LIKE ?",
                            ["%#{pattern}%", "%#{pattern}%", "%#{pattern}%", "%#{pattern}%"])
        when "2"
            puts "People (find \"#{pattern}\" in username)"
            rows = db.execute("SELECT * FROM people WHERE username LIKE ?", "%#{pattern}%")
        when "3"
            puts "People (find \"#{pattern}\" in name)"
            rows = db.execute("SELECT * FROM people WHERE name LIKE ?", "%#{pattern}%")
        when "4"
            puts "People (find \"#{pattern}\" in status)"
            rows = db.execute("SELECT * FROM people WHERE status LIKE ?", "%#{pattern}%")
        when "5"
            puts "People (find \"#{pattern}\" in updated)"
            rows = db.execute("SELECT * FROM people WHERE updated_at LIKE ?", "%#{pattern}%")
        when "6"
            if pattern.nil? || pattern.empty?
                print_missing_session_token
                return
            end
            person = Person.find_by_session(pattern)
            if person
                puts "People (find all)"
                puts "session #{pattern}"
                Person.people
            else
                print_invalid_session_token
            end
            return
        else
            puts "Invalid search type"
            return
        end
        db.close
        persons = rows.map { |row| new_from_row(row) }
        print_find(persons)
    end

    def self.sort(field, direction)
        if field == "updated"
            if direction == "asc"
                puts "People (sorted by #{field}, oldest)"
            else
                puts "People (sorted by #{field}, newest)"
            end
        else
            if direction == "asc"
                puts "People (sorted by #{field}, a-z)"
            else
                puts "People (sorted by #{field}, z-a)"
            end
        end
        if field == "updated"
            field = "updated_at"
        end
        allowed_fields = %w[username name status updated_at]
        allowed_directions = %w[asc desc]
        unless allowed_fields.include?(field) && allowed_directions.include?(direction)
            puts "not found"
            return
        end
        db = SQLite3::Database.new(DB_PATH)
        rows = db.execute("SELECT * FROM people ORDER BY #{field} #{direction}")
        db.close
        persons = rows.map { |row| new_from_row(row) }
        print_find(persons)
    end

    def self.print_person_details(person)
        puts "Person"
        puts "------"
        puts "name: #{person.name}"
        puts "username: #{person.username}"
        puts "status: #{person.status}"
        puts "updated: #{person.updated_at}"
    end

    def self.print_after_login(person)
        puts "Welcome back to the App, #{person.name}!"
        puts "\"#{person.status}\""
        puts "edit: ./app 'session #{person.session} edit'"
        puts "update: ./app 'session #{person.session} update (name=\"<value>\"|status=\"<value>\")+'"
        puts "logout: ./app 'session #{person.session} logout'"
        puts "people: ./app '[session #{person.session} ]people'"
    end

    def self.print_home_page
        puts "Welcome to the App!"
        puts "login: ./app 'login <username> <password>'"
        puts "join: ./app 'join'"
        puts "create: ./app 'create username=\"<value>\" password=\"<value>\" name=\"<value>\" status=\"<value>\"'"
        puts "people: ./app 'people'"
    end

    def self.print_invalid_session_token
        puts "invalid request: invalid session token"
        puts "home: ./app"
    end

    def self.print_invalid_missing_session_token
        puts "invalid request: missing session token"
        puts "home: ./app"
    end

    def self.print_missing_session_token
        puts "access denied: missing session token"
        puts "home: ./app"
    end

    def self.print_after_people_with_session(session)
        puts "find: ./app 'find <pattern>'"
        puts "sort: ./app 'sort[ username|name|status|updated[ asc|desc]]'"
        puts "update: ./app 'session #{session} update (name=\"<value>\"|status=\"<value>\")+'"
        puts "home: ./app ['session #{session}']"
    end

    def self.print_after_show_with_session(session)
        puts "logout: ./app 'session #{session} logout'"
        puts "people: ./app '[session #{session} ]people'"
        puts "home: ./app ['session #{session}']"
    end

    def self.print_all(session)
        puts "update: ./app 'session #{session} update (name=\"<value>\"|status=\"<value>\")+'"
        puts "delete: ./app 'session #{session} delete'"
        puts "edit: ./app 'session #{session} edit'"
        puts "logout: ./app 'session #{session} logout'"
        puts "people: ./app '[session #{session} ]people'"
        puts "home: ./app ['session #{session}']"
    end

    def self.print_after_people
        puts "find: ./app 'find <pattern>'"
        puts "sort: ./app 'sort[ username|name|status|updated[ asc|desc]]'"
        puts "join: ./app 'join'"
        puts "create: ./app 'create username=\"<value>\" password=\"<value>\" name=\"<value>\" status=\"<value>\"'"
        puts "home: ./app"
    end

    def self.print_after_show
        puts "\npeople: ./app 'people'"
        puts "home: ./app"
    end

    def self.print_find(persons)
        puts "----------------------------"
        persons.each do |person|
            puts "#{person.name} @#{person.username} (./app 'show #{person.username}')"
            puts "  #{person.status}"
            puts "  @ #{person.updated_at}"
        end
        puts "find: ./app 'find <pattern>'"
        puts "sort: ./app 'sort[ username|name|status|updated[ asc|desc]]'"
        puts "people: ./app 'people'"
        puts "join: ./app 'join'"
        puts "create: ./app 'create username=\"<value>\" password=\"<value>\" name=\"<value>\" status=\"<value>\"'"
        puts "home: ./app"
    end

    def self.encrypt_password(password)
        Digest::SHA256.hexdigest(password)
    end

    def self.generate_simple_base64_id(length)
        # Generate random bytes and encode them in base64
        random_bytes = Random.new.bytes(length)
        base64_encoded = Base64.strict_encode64(random_bytes) # Ensures no URL-safe characters
      
        # Optionally, you might want to truncate or pad to a specific length
        return base64_encoded[0...length] # Adjust length as needed
    end

    def verify_password(plain_password, encrypted_password)
        self.class.encrypt_password(plain_password) == encrypted_password
    end

    def self.invalid_param(param,value)
        if value.length < 1
            puts "failed to update: #{param} is too short"
            return true
        elsif value.length > 30
            puts "failed to update: #{param} is too long"
            return true
        end
        return false
      end

    def self.reset_database
        db = SQLite3::Database.new(DB_PATH)
        
        # Drop the table if it exists
        db.execute <<-SQL
            DROP TABLE IF EXISTS people;
        SQL
    
        db.close
    end

end

Person.setup_database

case ARGV[0]
when 'reset'
    Person.reset_database
end