# factories for all the models

FactoryGirl.define do
  # use sequences to dynamically create unique records on demand
  sequence :email do |n|
    "sarah#{n}@example.com"
  end

  sequence :contact_name do |n|
    "Sarah #{n}"
  end

  sequence :client_name do |n|
    "Client number #{n}"
  end

  factory :client do
  	# this lets factory girl save Sequel models
	to_create { |i| i.save }
    name 			{ generate(:client_name) }
    contact_name  	{ generate(:contact_name) }
    contact_email	{ generate(:email) }
    description 	"An important client"
  end
end
