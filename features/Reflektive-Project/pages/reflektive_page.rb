require 'date'

class UtilityPage

  attr_accessor :user_account_link, :sign_in, :modal_popup, :email, :password, :sign_button,
                :trip_type, :source_name, :destination_name, :depart_date, :return_date,
                :no_of_adult, :no_of_child, :search_btn, :last_flight, :itinerary_btn,
                :nationality, :mobile_number, :travel_continue_btn, :payment_submit_btn

  URL = $clear_trip_details['clear_trip']['site_url']
  USER_NAME = $clear_trip_details['clear_trip']['user_name']
  USER_PASSWORD = $clear_trip_details['clear_trip']['password']
  DEPART_DATE = (Date.today + 7).strftime('%d/%m/%Y')
  RETURN_DATE = (Date.today + 8).strftime('%d/%m/%Y')
  TRIP = $clear_trip_details['clear_trip']['trip_type']
  SOURCE_PLACE_NAME = $clear_trip_details['clear_trip']['source_name']
  DESTINATION_PLACE_NAME = $clear_trip_details['clear_trip']['destination_name']
  ADULT_COUNT = $clear_trip_details['clear_trip']['no_of_adults']
  CHILD_COUNT = $clear_trip_details['clear_trip']['no_of_children']
  MOBILE_NUMBER = $clear_trip_details['clear_trip']['mobile_no']

  def initialize(browser)
    @browser = browser
    @user_account_link = @browser.link(:id, 'userAccountLink')
    @sign_in = @browser.input(:title, 'Sign In')
    @modal_popup = @browser.div(:id, 'ModalFrame')
    @email = @modal_popup.iframe.form.text_field(:id, 'email')
    @password = @modal_popup.iframe.form.text_field(:id, 'password')
    @sign_button = @modal_popup.iframe.form.button(:id, 'signInButton')
    @trip_type = @browser.label(:title, TRIP)
    @source_name = @browser.text_field(:id, 'FromTag')
    @destination_name = @browser.text_field(:id, 'ToTag')
    @depart_date = @browser.text_field(:id, 'DepartDate')
    @return_date = @browser.text_field(:id, 'ReturnDate')
    @no_of_adult = @browser.select_list(:id, 'Adults')
    @no_of_child = @browser.select_list(:id, 'Childrens')
    @search_btn = @browser.button(:id, 'SearchBtn')
    @last_flight = @browser.uls(:class, 'list clearFix inline ')
    @itinerary_btn = @browser.button(:id, 'itineraryBtn')
    @nationality = @browser.text_fields(:placeholder, 'Nationality')
    @mobile_number = @browser.text_field(:id, 'mobileNumber')
    @travel_continue_btn = @browser.button(:id, 'travellerBtn')
    @payment_submit_btn = @browser.button(:id, 'paymentSubmit')
  end

  # Purpose - Navigating to Clear Trip site
  def visit
    @browser.goto(URL)
  end

  def login_to_site
    @user_account_link.wait_until(timeout: 60, &:present?).send_keys :enter
    @sign_in.wait_until(timeout: 60, &:present?).send_keys :enter
    @email.wait_until(timeout: 60, &:present?).set USER_NAME
    @password.wait_until(timeout: 60, &:present?).set USER_PASSWORD
    @sign_button.wait_until(timeout: 60, &:present?).send_keys :enter
    sleep(10)
  end

  def search_flight
    @trip_type.wait_until(timeout: 60, &:present?).click! unless @modal_popup.exists?
    @source_name.wait_until(timeout: 60, &:present?).set SOURCE_PLACE_NAME
    @destination_name.wait_until(timeout: 60, &:present?).set DESTINATION_PLACE_NAME
    @depart_date.wait_until(timeout: 60, &:present?).set DEPART_DATE
    @return_date.wait_until(timeout: 60, &:present?).set RETURN_DATE
    @no_of_adult.wait_until(timeout: 60, &:present?).select ADULT_COUNT.to_s
    @no_of_child.wait_until(timeout: 60, &:present?).select CHILD_COUNT.to_s
    @search_btn.wait_until(timeout: 60, &:present?).click!
    wait_until_true(150){@last_flight[2].lis[4].label.visible?}
    # Choosing the last flight on very next day
    @last_flight[2].lis[4].label.wait_until(timeout: 60, &:present?).click!
    p 'Click on the book button'
    @browser.buttons.each do |btn|
      btn.click! if btn.text == 'Book'
    end
  end

  # Purpose - Booking the flight ticket
  # Params - Passenger details - Hash value detail of person like name, dob, nationality
  def booking_of_flight(passenger_details)
    @modal_popup.a.click! if @modal_popup.exists? # if pop-up relating to "Try Again" comes, then close it
    @itinerary_btn.wait_until(timeout: 120, &:present?).click!
    sleep(10)

    @adult_iterator = 1
    @child_iterator = 1
    @iterator = 1
    passenger_details.each do |passgr|
      person_type = passgr['Person']
      title = passgr['Passenger_name'].split(' ')[0]
      first_name = passgr['Passenger_name'].split(' ')[1]
      second_name = passgr['Passenger_name'].split(' ')[2]
      dob_day = passgr['DateOfBirth'].split('/')[0]
      dob_month = passgr['DateOfBirth'].split('/')[1]
      dob_year = passgr['DateOfBirth'].split('/')[2]
      nationality = passgr['Nationality']
      val = person_type == 'Adult' ? @adult_iterator : @child_iterator
      @browser.select_list(:id, "#{person_type}Title#{val}").select title
      @browser.text_field(:id, "#{person_type}Fname#{val}").set first_name
      @browser.text_field(:id, "#{person_type}Lname#{val}").set second_name
      @browser.select_list(:id, "#{person_type}DobDay#{val}").select dob_day if @browser.select_list(:id, "#{person_type}DobDay#{val}").exists?
      @browser.select_list(:id, "#{person_type}DobMonth#{val}").select dob_month if @browser.select_list(:id, "#{person_type}DobMonth#{val}").exists?
      @browser.select_list(:id, "#{person_type}DobYear#{val}").select dob_year if @browser.select_list(:id, "#{person_type}DobYear#{val}").exists?
      @nationality[@iterator - 1].set nationality if @nationality.count > 0
      @adult_iterator += 1 if person_type == 'Adult'
      @child_iterator += 1 if person_type == 'Child'
      @iterator += 1
    end
    p 'Provide your contact details' if @mobile_number.set MOBILE_NUMBER
    @travel_continue_btn.wait_until(timeout: 60, &:present?).click!
    sleep(10)
    @modal_popup.a.click! if @modal_popup.exists?
  end

  # Purpose - Make payment for the flight ticket
  # Params - nil
  def flight_payment_gateway
    res = false
    begin
      res = true if @payment_submit_btn.wait_until(timeout: 60, &:present?).exists?
      p 'Payment for the flight ticket follows from HERE'
    rescue
      res = false
    end
    res
  end

  # Purpose - Method to make block wait until block returns TRUE
  def wait_until_true(seconds = 150)
    end_time = Time.now + seconds
    begin
      yield
    rescue StandardError => e
      raise e.message if Time.now >= end_time
      puts "Got #{e.message}, hence retrying...!"
      sleep 3
      retry
    end
  end
end
