# exec_command.rb
require_relative "person"

def process_command(command)
    if command == "spec/person_spec.rb"
        return
    end
    if command.match(/^login\s*(\S*)\s*(\S*)$/)
        # last case is failing
        username = $1
        password = $2
        Person.login(username, password)
    elsif command.match(/^show\s*(\S*)/)
        # last case is failing
        username = $1
        Person.find_by_username(username)
    elsif command.match(/^session\s+(\S+)\s+show\s+(\S+)$/)
        session= $1
        username = $2
        Person.show_with_session(session, username)
    elsif command.match(/^session\s+(\S+)\s+update\s*(.*)$/)
        session = $1
        update_params = $2
        if update_params.match(/name="([^"]*)"/)
          name = $1
        end      
        if update_params.match(/status="([^"]*)"/)
          status = $1
        end
        Person.update(session,name,status)
    elsif command.match(/session\s*(\S*)\s*(\S*)$/)
        session = $1
        action = $2
        case action
        when "logout"
            Person.logout(session)
        when "home"
            Person.home_with_session(session)
        when ""
            Person.home_with_session(session)
        when "people"
            Person.people_with_session(session)
        when "edit"
            Person.edit(session)
        when "delete"
            Person.delete(session)
        when "find"
            Person.find_by_pattern("6",session)
        else
            Person.check_session(session) 
            puts "Invalid command"
        end
    elsif command.match(/^find\s*(.*?)\s*$/)
        pattern =$1.strip

        if pattern.match(/^username:\s*(.+)$/)
            value = $1.strip
            Person.find_by_pattern("2",value)
        elsif pattern.match(/^name:\s*(.+)$/)
            value = $1.strip
            Person.find_by_pattern("3",value)
        
        elsif pattern.match(/^status:\s*(.+)$/)
            value = $1.strip
            Person.find_by_pattern("4",value)
        
        elsif pattern.match(/^updated:\s*(.+)$/)
            value = $1.strip
            Person.find_by_pattern("5",value)
        
        else
            value = pattern.strip
            Person.find_by_pattern("1",value)
        end
    elsif command.match(/^sort(?:\s+(\S+))?(?:\s+(\S+))?$/)
        field = $1
        order = $2
    
        # Default to sorting by 'updated' in descending order if no field is specified
        field = 'updated' if field.nil?
        # order = 'asc' if order.nil?
        if order.nil?
            order = field == 'updated' ? 'desc' : 'asc'
        end
    
        Person.sort(field,order)
    elsif command.match('logout')
        Person.logout('')
    elsif command.match('edit')
        Person.edit('')
    elsif command.match('delete')
        Person.delete('')
    elsif command.match('sort')
        Person.sort('updated','desc')
    elsif command.match('update')
        Person.update('','','')
    elsif command.start_with?('create')
        if command.match(/username="([^"]*)"/)
            username = $1
        end
        
        if command.match(/password="([^"]*)"/)
            password = $1
        end
        
        if command.match(/ name="([^"]*)"/)
            name = $1
        end
        
        if command.match(/status="([^"]*)"/)
            status = $1
        end
        Person.create(username,password,name,status)
    elsif command.match('people')
        Person.people
    elsif command.match('join')
        Person.join
    elsif command.match('home')
        Person.print_home_page
    elsif command.empty?
        Person.print_home_page
    else
        puts "not found"
        puts "home: ./app"
    end
  end
  
  # Get the command from the arguments
  if ARGV.length > 0
    command = ARGV[0]
    process_command(command)
  else
    puts "No command provided."
  end
  