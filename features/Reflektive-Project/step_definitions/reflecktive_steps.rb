
Given(/^navigate to site$/) do
  @cleartrip = UtilityPage.new(@browser)
  logger.info 'Navigating to clear trip site'
  @cleartrip.visit
end

And(/^login to clear trip site$/) do
  logger.info 'Logging to the Clear Trip site'
  @cleartrip.login_to_site
end

When(/^Search for cheapest flight$/) do
  logger.info 'Searching for the cheapest flight'
  @cleartrip.search_flight
end

Then(/^Fill details for flight ticket:$/) do |table|
  # table is a table.hashes.keys # => [:Passenger_name, :DateOfBirth, :Nationality]
  passenger_details = table.hashes
  logger.info 'Fill the details relevant for booking flight ticket'
  @cleartrip.booking_of_flight(passenger_details)
end

And(/^Make payment of flight ticket$/) do
  logger.info 'Moving towards payment of flight tickets'
  expect(@cleartrip.flight_payment_gateway).to eq(true), "It didn't reach till payment gateway"
end