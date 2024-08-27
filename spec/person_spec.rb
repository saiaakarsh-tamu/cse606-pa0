require_relative "../statusboard/person"
require 'sqlite3'
require 'rspec'

RSpec.describe Person do

    #Test case for initialize function
    describe '#initialize' do
        let(:person) do
        Person.new(
            username: 'testuser',
            password: 'password123',
            name: 'Test User',
            status: 'active',
            session: 'session_token',
            id: 1,
            created_at: Time.now,
            updated_at: Time.now
        )
        end

        it 'sets the username' do
        expect(person.username).to eq('testuser')
        end

        it 'sets the password' do
        expect(person.password).to eq('password123')
        end

        it 'sets the name' do
        expect(person.name).to eq('Test User')
        end

        it 'sets the status' do
        expect(person.status).to eq('active')
        end

        it 'sets the session' do
        expect(person.session).to eq('session_token')
        end

        it 'sets the id' do
        expect(person.id).to eq(1)
        end

        it 'sets the created_at' do
        expect(person.created_at).not_to be_nil
        end

        it 'sets the updated_at' do
        expect(person.updated_at).not_to be_nil
        end

        it 'sets skip_validation to false by default' do
        expect(person.skip_validation).to be(false)
        end
    end

    # describe '.login' do
    #     let(:username) { 'testuser' }
    #     let(:password) { 'testpassword' }
    #     let(:person) { instance_double('Person', session: nil, password: 'hashed_password') }
    #     let(:db) { instance_double('SQLite3::Database') }
    
    #     before do
    #         allow(SQLite3::Database).to receive(:new).and_return(db)
    #         allow(db).to receive(:execute).with("SELECT * FROM people WHERE username = ?", username).and_return([['username', 'hashed_password']])
    #         allow(db).to receive(:close)
    #         allow(Person).to receive(:new_from_row).and_return(person)
    #         allow(person).to receive(:verify_password).with(password, person.password).and_return(true)
    #         allow(Person).to receive(:generate_simple_base64_id).and_return('session_id')
    #         allow(person).to receive(:update_session).and_return(true)
    #         allow(Person).to receive(:find_by_session).and_return(person)
    #     end
    
    #     context 'when username is empty' do
    #         it 'prints an invalid request message' do
    #             expect { Person.login('', password) }.to output(/invalid request: missing username and password/).to_stdout
    #         end
    #     end
    
    #     context 'when password is empty' do
    #         it 'prints an incorrect username or password message' do
    #             expect { Person.login(username, '') }.to output(/incorrect username or password/).to_stdout
    #         end
    #     end
    
    #     context 'when username and password are correct' do
    #         it 'logs the user in and prints the after login message' do
    #             allow(person).to receive(:session).and_return('session_id')
        
    #             expect { Person.login(username, password) }.to output(/home: \.\/app/).to_stdout
    #         end
    #     end
    
    #     context 'when username or password is incorrect' do
    #         it 'prints an access denied message' do
    #             allow(person).to receive(:verify_password).and_return(false)
        
    #             expect { Person.login(username, password) }.to output(/access denied: incorrect username or password/).to_stdout
    #         end
    #     end
    # end

    describe '.print_after_login' do
        let(:person) { instance_double('Person', name: 'Sai', status: 'sleep', session: 'abcdef') }
    
        it 'prints the correct messages after login' do
            expected_output = <<~OUTPUT
                Welcome back to the App, Sai!
                "sleep"
                edit: ./app 'session abcdef edit'
                update: ./app 'session abcdef update (name="<value>"|status="<value>")+'
                logout: ./app 'session abcdef logout'
                people: ./app '[session abcdef ]people'
            OUTPUT
        
            expect { Person.print_after_login(person) }.to output(expected_output).to_stdout
        end
    end

    describe '.print_person_details' do
        let(:person) { instance_double('Person', name: 'Sai', status: 'sleep', username:'sai', updated_at:'2024-09-19 20:34:01') }
    
        it 'prints the person details' do
            expected_output = <<~OUTPUT
                Person
                ------
                name: Sai
                username: sai
                status: sleep
                updated: 2024-09-19 20:34:01
            OUTPUT
        
            expect { Person.print_person_details(person) }.to output(expected_output).to_stdout
        end
    end

    describe '.print_home_page' do
    
        it 'prints the home page' do
            expected_output = <<~OUTPUT
                Welcome to the App!
                login: ./app 'login <username> <password>'
                join: ./app 'join'
                create: ./app 'create username=\"<value>\" password=\"<value>\" name=\"<value>\" status=\"<value>\"'
                people: ./app 'people'
            OUTPUT
        
            expect { Person.print_home_page }.to output(expected_output).to_stdout
        end
    end
end