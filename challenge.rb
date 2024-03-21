require 'json'
require_relative "company"

class Challenge

    # initialize our list of companies and users from our spreadsheet
    def initialize
        @companies = parse_companies
        @users = parse_users
    end

    def calculate_companies
        File.open("output.txt", "a") do |file|
            @companies.each do |company_data|
                company = Company.new(company_data)
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
        # initialize a varaible to track our token total
        total = 0

        output = "\n\tCompany Id: #{company.id}\n"
        output << "\tCompany Name: #{company.name}\n" 

        output << "\tUsers Emailed:\n"
        company_email_users = company_users(company, true)
        company_email_users.sort_by! { |user| user["last_name"] }
        if company.email_status
            company_email_users.each do |user|
                total += company.top_up
                write_user_details(output, user, company)
            end
        end

        output << "\tUsers Not Emailed:\n"
        company_users = company_users(company, false)
        company_users.sort_by! { |user| user["last_name"] }
        company_users.each do |user|
            total += company.top_up
            write_user_details(output, user, company)
        end
        output << "\t\tTotal amount of top ups for #{company.name}: #{total}\n"
    end

    # Define a helper method to write user details to the file
    def write_user_details(output, user, company)
        output << "\t\t#{user["last_name"]}, #{user["first_name"]}, #{user["email"]}\n"
        output << "\t\t  Previous Token Balance, #{user["tokens"]}\n"
        output << "\t\t  New Token Balance #{user["tokens"] + company.top_up}\n"
    end

    # If we chose to email users, we should grab that list of users with the ability to be emailed
    def company_users(company, email_status)
        @users.select { |user| user["company_id"] == company.id && user["active_status"] == true && (!company.email_status || user["email_status"] == email_status) }
    end
end

Challenge.new.calculate_companies