#!/usr/bin/env ruby

require 'json'

# parse JSON files with error handling
def parse_json_files(file_name)
    JSON.parse(File.read(file_name))
rescue Errno::ENOENT
    raise "Error: File '#{file_name}' not found."
rescue JSON::ParserError
    raise "Error: Invalid JSON in '#{file_name}'."
end

# create user output
def format_user(user, previous_balance, new_balance)
    "    #{user['last_name']}, #{user['first_name']}, #{user['email']}\n" \
    "      Previous Token Balance, #{previous_balance}\n" \
    "      New Token Balance #{new_balance}\n"
end

# create company output
def format_company_output(company, emailed_users, not_emailed_users, total_top_up)
    output = "Company Id: #{company['id']}\n"
    output += "Company Name: #{company['name']}\n"
    output += "Users Emailed:\n#{emailed_users.join}"
    output += "Users Not Emailed:\n#{not_emailed_users.join}"
    output += "    Total amount of top ups for #{company['name']}: #{total_top_up}\n\n"
    output
end

# process data and create output
def process_data(users, companies)
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
        output += format_company_output(company, emailed_users, not_emailed_users, total_top_up)
    end

    output
end

begin
    puts "Starting processing..."
    # Load companies & users from JSON files
    companies = parse_json_files('companies.json')
    users = parse_json_files('users.json')

    # process user & companies to generate output
    output = process_data(users, companies)

    # Write output to file
    File.write('output.txt', output)
    puts "Processing finished. Output written to 'output.txt'"
rescue StandardError => e
    puts "An error occurred: #{e.message}"
    exit 1
end