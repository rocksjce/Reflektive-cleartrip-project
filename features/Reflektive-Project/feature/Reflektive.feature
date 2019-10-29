
  Feature: Book cheapest flight ticket in "Cleartrip" site

  Scenario: Navigate to clear trip page
      Given navigate to site
      And login to clear trip site
      When Search for cheapest flight
      Then Fill details for flight ticket:
      | Passenger_name   | DateOfBirth | Nationality | Person|
      | Mr Rohit Sharma  | 29/Oct/1990 | India       | Adult |
      | Mrs Ruby Sharma  | 14/Sep/1995 | India       | Adult |
      | Miss Riya Sharma | 12/Dec/2008 | India       | Child |
      And Make payment of flight ticket
