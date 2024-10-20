#!/usr/bin/env ruby

require 'json'

# create user output
def format_user(user, previous_balance, new_balance)
    "    #{user['last_name']}, #{user['first_name']}, #{user['email']}\n" \
    "      Previous Token Balance, #{previous_balance}\n" \
    "      New Token Balance #{new_balance}\n"
end

begin
    # Load companies from JSON file
    companies = JSON.parse(File.read('companies.json'))
    # Load users from JSON file
    users = JSON.parse(File.read('users.json'))

    output = ""

    # for each company (sorted by id):
    companies.sort_by { |c| c['id'] }.each do |company|
        emailed_users = []
        not_emailed_users = []
        total_top_up = 0

        # for each active user in company (sorted by last name):
        users.select { |u| u['company_id'] == company['id'] && u['active_status'] }
            .sort_by { |u| u['last_name'] }
            .each do |user|
            
            # calculate new token balance
            prev_balance = user['tokens']
            new_balance = prev_balance + company['top_up']

            # create user output
            user_info = format_user(user, prev_balance, new_balance)

            # add user to emailed or non-emailed list
            if user['email_status'] && company['email_status']
                emailed_users << user_info
            else
                not_emailed_users << user_info
            end

            # calculate total top-up for company
            total_top_up += company['top_up']
        end

        # create company output
        output += "Company Id: #{company['id']}\n"
        output += "Company Name: #{company['name']}\n"
        output += "Users Emailed:\n"
        output += emailed_users.join
        output += "Users Not Emailed:\n"
        output += not_emailed_users.join
        output += "    Total amount of top ups for #{company['name']}: #{total_top_up}\n\n"
    end
    # Write output to file
    File.write('output.txt', output)
end