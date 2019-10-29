# require 'require_all'
# require_all './Reflektive-Project/pages/utility.rb'
require 'rubygems'
require 'rspec'
require 'watir'
require 'net/http'
require 'uri'
require 'openssl'
require 'logger'

include Selenium

#Creating Remote WebDriver
# Browser  - IE
iedriver_path = File.join(File.absolute_path('../..', File.dirname(__FILE__)),"exe","IEDriverServer.exe")
Selenium::WebDriver::IE.driver_path = iedriver_path
browser = Watir::Browser.new :ie
browser.window.maximize
#Browser - Chrome
# chromedriver_path = File.join(File.absolute_path('../..', File.dirname(__FILE__)),"exe","chromedriver.exe")
# Selenium::WebDriver::Chrome.driver_path = chromedriver_path
# # chrome_options = webdriver.ChromeOptions()
# browser = Watir::Browser.new :chrome
# browser.window.maximize


Before do
  @browser = browser
end

at_exit do
  browser.close
end

After do
  @browser.cookies.clear
end

module SpecLogger
  def logger
    @logger ||= begin
      l = Logger.new(STDOUT)
      l.level = Logger::DEBUG
      l
    end
  end
end

World(SpecLogger)