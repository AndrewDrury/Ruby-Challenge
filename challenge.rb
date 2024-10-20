#!/usr/bin/env ruby

require 'json'


begin
    # Load companies from JSON file
    companies = JSON.parse(File.read('companies.json'))
    # Load users from JSON file
    users = JSON.parse(File.read('users.json'))

    # for each company (sorted by id):
    companies.sort_by { |c| c['id'] }.each do |company|
        # for each active user in company (sorted by last name):
        users.select { |u| u['company_id'] == company['id'] && u['active_status'] }
            .sort_by { |u| u['last_name'] }
            .each do |user|
            
            # calculate new token balance
            prev_balance = user['tokens']
            new_balance = prev_balance + company['top_up']

            # create user output
            puts "#{user['last_name']}, #{user['first_name']}, #{user['email']}"
            puts "Previous Token Balance, #{prev_balance}"
            puts "New Token Balance #{new_balance}\n"

            # add user to emailed or non-emailed list
            # calculate total top-up for company
        end

        # create company output
        puts "Company #{company['name']}"
        # add company output to overall output
    end
    # Write output to file
end