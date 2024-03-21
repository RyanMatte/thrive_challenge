require 'json'
require_relative "company"

class Challenge

    # initialize our list of companies and users from our spreadsheet
    def initialize
        @companies = parse_companies
        @users = parse_users
    end

    def calculate_companies
        File.open("output.txt", "w") do |file|
            @companies.each do |company_data|
                company = Company.new(company_data)
                next if empty_users?(company)
                file.write(print_company(company)) 
            end
        end
    end

    private

    # retrieve company list
    def parse_companies 
        company_data = File.read("companies.json")
        JSON.parse(company_data)
    end

    # retrieve our user list
    def parse_users 
        user_data = File.read("users.json")
        JSON.parse(user_data)  
    end

    def print_company(company)
        total = 0
        output = "\n\tCompany Id: #{company.id}\n"
        output << "\tCompany Name: #{company.name}\n" 
        output << "\tUsers Emailed:\n"
        total += print_users(company, true, output)
        output << "\tUsers Not Emailed:\n"
        total += print_users(company, false, output)
        output << "\t\tTotal amount of top ups for #{company.name}: #{total}\n"
    end

    def print_users(company, emailed, output)
        total = 0
        company_users = company_users(company, emailed)
        company_users.sort_by! { |user| user["last_name"] }
        if company.email_status || !emailed
            company_users.each do |user|
                total += company.top_up
                write_user_details(output, user, company)
            end
        end
        total
    end

    # Define a helper method to write user details to the file
    def write_user_details(output, user, company)
        output << "\t\t#{user["last_name"]}, #{user["first_name"]}, #{user["email"]}\n"
        output << "\t\t  Previous Token Balance, #{user["tokens"]}\n"
        output << "\t\t  New Token Balance #{user["tokens"] + company.top_up}\n"
    end

    def empty_users?(company)
        user_list = @users.select { |user| user["company_id"] == company.id }
        user_list.empty?
    end

    # If we chose to email users, we should grab that list of users with the ability to be emailed
    def company_users(company, email_status)
        @users.select { |user| user["company_id"] == company.id && user["active_status"] == true && (!company.email_status || user["email_status"] == email_status) }
    end
end

Challenge.new.calculate_companies