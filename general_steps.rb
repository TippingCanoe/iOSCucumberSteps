Given /^the app is running beta$/ do
  element_exists("This is Beta")
  sleep(STEP_PAUSE)
end

Then /^I wait for the text "([^\"]*)" to appear$/ do |text|
	text = escape_quotes(text)
	wait_for_elements_exist(["label text:'#{text}'"], :timeout => WAIT_TIMEOUT)
end

Then /^I wait for the text "([^\"]*)" to appear somewhere$/ do |text|
	text = escape_quotes(text)
  	wait_for_elements_exist(["label {text CONTAINS '#{text}'}"], :timeout => WAIT_TIMEOUT)
end

Then /^I (should|should not) see the text "([^\"]*)" appear somewhere$/ do |opt, text|
	text = escape_quotes(text)

	seen = false;
  	seen = seen || element_exists("Label {text CONTAINS '#{text}'}")
  	seen = seen || element_exists("TextView {text CONTAINS '#{text}'}")
  	seen = seen || element_exists("TextField {text CONTAINS '#{text}'}")

  	if opt == "should" and not seen
  		screenshot_and_raise "Text '#{text}' does not appear anywhere"
  	elsif opt == "should not" and seen
  		screenshot_and_raise "Text '#{text}' appears somewhere, it was not supposed to"
	end  		
end


Then /^I (should|should not) see the keyboard$/ do |opt|
    if opt == "should" and not element_exists("keyboardAutomatic") 
    	raise "Expected keyboard to be visible."
    elsif opt == "should not" and element_exists("keyboardAutomatic")
    	raise "Did not expect keyboard to be visible."
    end
end

Then /^I wait (to|to not) see the keyboard$/ do |opt|
	if opt == "to"
		wait_for_elements_exist(["keyboardAutomatic"], :timeout => WAIT_TIMEOUT)
	else
		wait_for_elements_do_not_exist(["keyboardAutomatic"], :timeout => WAIT_TIMEOUT)
	end
end

Then /^I enter "(.*?)" into "(.*?)"$/ do |text,field|
	query = "view marked:'#{field}'"

	enterTextWithKeyboard(query, text)
end

Then /^I enter random text into "(.*?)"$/ do |text,field|
	query = "view marked:'#{field}'"
	stamp = (Time.now.to_f*1000).to_i.to_s
	text = "poop" + stamp
	enterTextWithKeyboard(query, text)
end

Then /^I enter random email into "(.*?)"$/ do |text,field|
	query = "view marked:'#{field}'"
	stamp = (Time.now.to_f*1000).to_i.to_s
	text = "poop" + stamp + "@poop.com"
	enterTextWithKeyboard(query, text)
end

Then /^I wait for the loading flame animation to (start|stop)$/ do |opt|

	wait_for(
		:timeout => WAIT_TIMEOUT,
		:timeout_message => "Timed out waiting for the loading flame animation to " + opt) do
		
		description = query("view marked:'LoadFlameImage'").join()
		#puts description.inspect

		(description.include? 'animations') == (opt == 'start')
	end
end

Then /^I wait for the list to refresh$/ do
	step 'I wait for the loading flame animation to start'
	step 'I wait for the loading flame animation to stop'
end

Then /^I should see the "([^\"]*)" set to (Yes|No|On|Off)$/ do |name,opt|
	status = query("view marked:'#{name}'",:isOn).first.to_i

	if opt == "Yes" or opt == "On" and status == 0
		raise "#{name} is set to " + status.to_s + ", expected was 1"
	elsif opt == "No" or opt == "Off" and status == 1
		raise "#{name} is set to " + status.to_s + ", expected was 0"
	end
end

Then /^I set the "([^\"]*)" to (Yes|No|On|Off)$/ do |name,opt|
	status = query("view marked:'#{name}'",:isOn).first.to_i

	if ((opt == "Yes" or opt == "On") and status == 0) or ((opt == "No" or opt == "Off") and status == 1)
		touch("view marked:'#{name}'")
		sleep(STEP_PAUSE)
	end
end

Then /^I touch a random element of the "([^\"]*)" type$/ do |type|
	elements = query("view:'#{type}'")

	if elements.count > 0
		index = rand(elements.count)
		puts index
		
		#if the type has only one view and you refer it to as index "0" then calabash will crash
		if index == 0
			touch("view:'#{type}'")
		else
			touch("view:'#{type}' index:" + index.to_s)
		end
	else 
		screenshot_and_raise "No views of type '" + type + "' found!"
	end
end

Then /^I touch element (\d+) of the "([^\"]*)" type$/ do |index, type|
	elements = query("view:'#{type}'")
	index = index.to_i

	if index < elements.count and index >= 0

		#if the type has only one view and you refer it to as index "0" then calabash will crash
		if index == 0
			touch("view:'#{type}'")
		else
			touch("view:'#{type}' index:" + index.to_s)
		end
	else 
		screenshot_and_raise "Index specified violates item array constraint! Specified: " + index.to_s + " array count: " + elements.count.to_s
	end
end

Then /^I (should|should not) see (an element|elements) of the "([^\"]*)" type$/ do |opt,plu,type|
	elements = query("view:'#{type}'")

	if opt == "should" and elements.count <= 0
		raise "Was expecting to see elements of type " + type.inspect + " but saw none"
	elsif opt == "should not" and elements.count > 0
		raise "Was not expecting to see any elements of type " + type.inspect + " but saw " + elements.count.to_s
	end
end

Then /^I should see (\d+) (elements|element) of the "(.*?)" type$/ do |num, plu, type|
	elements = query("view:'#{type}'")
	got = elements.count

	if got != num.to_i
		screenshot_and_raise "Was expecting to see #{num} of #{type} but saw #{got}"
	end
end

Then /^I (should|should not) see the focus set to "(.*?)"$/ do |opt, view|

	focus = query("view marked:'#{view}'",:isFirstResponder)

	if opt == "should" and focus == 0
		screenshot_and_raise ("'#{view}' does not have focus but it was supposed to!")
	elsif opt == "should not" and focus == 1
		screenshot_and_raise ("'#{view}' has focus but it was not supposed to!")
	end
end

Then /^I scroll (up|down|left|right) on "(.*?)" until I see "(.*?)"$/ do |dir, parent, view| 

	maxScrolls = 100
	count = 0
	element = query("view marked:'#{parent}' descendant view marked:'#{view}'")
	text = query("view marked:'#{parent}' descendant label text:'#{text}'")

	while element.empty? and text.empty? and count < maxScrolls do
		scroll("view marked:'#{parent}'", dir)
		sleep(STEP_PAUSE)
		element = query("view marked:'#{parent}' descendant view marked:'#{view}'")
		text = query("view marked:'#{parent}' descendant label text:'#{text}'")
		count+=1
	end
end

Then /^I scroll (up|down|left|right) until I see "(.*?)"$/ do |dir, view| 

	maxScrolls = 100
	count = 0
	element = query("view marked:'#{view}'")
	text = query("label text:'#{text}'")

	while element.empty? and text.empty? and count < maxScrolls do
		scroll("view", dir)
		sleep(STEP_PAUSE)
		element = query("view marked:'#{view}'")
		text = query("label text:'#{text}'")
		count+=1
	end
end

Then /^I should see that "(.*?)" is (selected|not selected)$/ do |view,opt|

	sel = query("view marked:'#{view}'",:isSelected).first.to_i

	if opt == "selected" and sel == 0
		screenshot_and_raise ("'#{view}' is not selected but it was supposed to be!")
	elsif opt == "not selected" and sel == 1
		screenshot_and_raise ("'#{view}' is selected but it's not supposed to be!")
	end
end

Then /^I should see that "(.*?)" is scrolled to the top$/ do |view|
	offY = query("view marked:'#{view}'", :contentOffset).first["Y"]

	if offY!=0
		screenshot_and_raise "The Y contentOffset for '#{view}' is not 0, thus it's not scrolled to the top"
	end
end

Then /^I touch "(.*?)" with offset (\d+),(\-?\d+)$/ do |view, xOffset, yOffset|

	viewQ = "view marked:'#{view}'"
	textQ = "label text:'#{view}'"

	query = viewQ
	
	if (element_exists(textQ) and not element_exists(viewQ))
		query = textQ
	end

	touch (query, :offset =>{:x=>xOffset,:y=>yOffset})
end


Then /^I randomly scroll (up|down|left|right)$/ do |dir| 

	maxScrolls = 10

	n = 1 + rand(maxScrolls)
	count = 0

	while count < n do
		scroll("view", dir)
		sleep(STEP_PAUSE)
		count+=1
	end

	puts "Scrolled #{dir} #{count} times"
end

def isIpad
	device = server_version['simulator_device'] 

	return device == "iPad"
end

def enterTextWithKeyboard(field, text)
	touch (field)
	wait_for_elements_exist(["keyboardAutomatic"], :timeout => WAIT_TIMEOUT)
	sleep (STEP_PAUSE)
	clearField(field)
	keyboard_enter_text(text)
	sleep (STEP_PAUSE)
	
	dismissKeyboard
	
	sleep (STEP_PAUSE)
	#wait_for_elements_do_not_exist(["keyboardAutomatic"], :timeout => WAIT_TIMEOUT)
	#sleep (STEP_PAUSE)
end

def clearField(fieldQuery)

	keyboardOn = element_exists("keyboardAutomatic")

	if not keyboardOn
		touch (fieldQuery)
		sleep (STEP_PAUSE)
	end
	
	wait_for_elements_exist(["keyboardAutomatic"], :timeout => WAIT_TIMEOUT)
	text = query(fieldQuery, :text).first.to_s

	for i in 0..text.length
		keyboard_enter_char("Delete")
	end

	if not keyboardOn
		dismissKeyboard
		sleep (STEP_PAUSE)
	end
end


def dismissKeyboard

	closeButton = "label text:'Close'"

	if (element_exists(closeButton))
		touch (closeButton)
	else
		if isIpad
			keyboard_enter_char("Dismiss")
		else
			keyboard_enter_char("Return")
		end
	end
end
