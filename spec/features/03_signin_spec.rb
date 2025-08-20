require "rails_helper"

describe "/users/sign_in" do
  it "has form to sign in a User", points: 1 do
    visit "/users/sign_in"

    expect(page).to have_tag("form", :count => 1),
      "Expect '/users/sign_in' page to have exactly one form tag, but couldn't find one."
  end
end

describe "/users/sign_in" do
  it "has a label with the text 'Email'", points: 1 do
    visit "/users/sign_in"

    expect(page).to have_tag("label", :text => /Email/i, :count => 1),
      "Expected page to have exactly 1 label tag with text 'Email', but didn't find one."
  end
end

describe "/users/sign_in" do
  it "has a label with the text 'Password'", points: 1 do
    visit "/users/sign_in"

    expect(page).to have_tag("label", :text => /Password/i, :count => 1),
      "Expected page to have exactly 1 label tag with text 'Password', but didn't find one."
  end
end

describe "/users/sign_in" do
  it "redirects you to the homepage when form is submitted", :points => 1 do
    the_user = User.new
    the_user.username = "testuser"
    the_user.email = "claire@example.com"
    the_user.password = "password"
    the_user.save

    visit "/users/sign_in"

    within(:css, "form") do
      fill_in "Email", with: the_user.email
      fill_in "Password", with: the_user.password
      click_button "Log in"
    end

    expect(page.current_path).to eq("/")
  end
end

describe "/users/sign_in" do
  it "displays the 'Sign out' link when user is signed in", :points => 1 do
    the_user = User.new
    the_user.username = "testuser"
    the_user.email = "claire@example.com"
    the_user.password = "password"
    the_user.save

    visit "/users/sign_in"

    within(:css, "form") do
      fill_in "Email", with: the_user.email
      fill_in "Password", with: the_user.password
      click_button "Log in"
    end

    expect(page).to have_tag("a", :text => /Sign out/i)
  end
end

describe "/users/sign_up" do
  it "has form to sign up a User", points: 1 do
    visit "/users/sign_up"

    expect(page).to have_tag("form", :count => 1),
      "Expect '/users/sign_up' page to have exactly one <form> tag, but couldn't find one."
  end
end

describe "/users/sign_up" do
  it "has a label with the text 'Email'", points: 1 do
    visit "/users/sign_up"

    expect(page).to have_tag("label", :text => /Email/i, :count => 1),
      "Expected page to have exactly 1 label tag with text 'Email', but didn't find one."
  end
end

describe "/users/sign_up" do
  it "has a label with the text 'Username'", points: 1 do
    visit "/users/sign_up"

    expect(page).to have_tag("label", :text => /Username/i, :min => 1),
      "Expected page to have at least 1 label tag with text 'Username', but didn't find one."
  end
end

describe "/users/sign_up" do
  it "has a label with the text 'Password'", points: 1 do
    visit "/users/sign_up"

    expect(page).to have_tag("label", :text => /Password\b*$/i, :min => 1),
      "Expected page to have at least 1 label tag with text 'Password', but didn't find one."
  end
end

describe "/users/sign_up" do
  it "has a label with the text 'Password confirmation'", points: 1 do
    visit "/users/sign_up"

    expect(page).to have_tag("label", :text => /Password confirmation/i, :min => 1),
      "Expected page to have at least 1 label tag with text 'Password confirmation', but didn't find one."
  end
end

describe "/users/sign_up" do
  it "creates a new user record when the form is submitted", :points => 1 do
    user_count = User.all.count

    visit "/users/sign_up"

    within(:css, "form") do
      fill_in "Username", with: "newuser"
      fill_in "Email", with: "newuser@example.com"
      fill_in "Password", with: "password"
      fill_in "Password confirmation", with: "password"
      click_on "Sign up"
    end

    expect(user_count).to be < User.all.count
  end
end
