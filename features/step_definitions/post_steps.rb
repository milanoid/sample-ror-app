Given('I am on the posts page') do
  visit '/posts'
end

Then('I should see {string}') do |text|
  expect(page).to have_content(text)
end
