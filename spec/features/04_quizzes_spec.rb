require "rails_helper"

describe "/quizzes" do
  it "requires user to be signed in", points: 1 do
    visit "/quizzes"

    expect(page.current_path).to eq("/users/sign_in"),
      "Expected to be redirected to sign in page when not logged in, but wasn't."
  end
end

describe "/quizzes" do
  it "lists the topics of each Quiz record for the current user", points: 2 do
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

    quiz_math = Quiz.new
    quiz_math.topic = "Mathematics"
    quiz_math.user_id = the_user.id
    quiz_math.save

    visit "/quizzes"

    expect(page).to have_text(quiz_math.topic),
      "Expected page to have the topic, '#{quiz_math.topic}'"
  end
end

describe "/quizzes" do
  it "has a form to create a new quiz", points: 1 do
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

    visit "/quizzes"

    expect(page).to have_css("form", minimum: 1)
  end
end

describe "/quizzes" do
  it "has a label for 'Topic' with text: 'Topic'", points: 1 do
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

    visit "/quizzes"

    expect(page).to have_css("label", text: "Topic")
  end
end

describe "/quizzes" do
  it "creates a Quiz when 'Create quiz' form is submitted", points: 5 do
    # Mock AI::Chat to avoid making actual API calls during tests
    allow(AI::Chat).to receive(:new).and_return(double(
      model: "gpt-4",
      "model=" => nil,
      add: nil,
      generate!: "This is a mocked response from the AI assistant. Question 1: What is 2 + 2?"
    ))
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

    initial_number_of_quizzes = Quiz.count
    test_topic = "Ruby Programming"

    visit "/quizzes"

    fill_in "Topic", with: test_topic
    click_on "Create quiz"

    final_number_of_quizzes = Quiz.count
    expect(final_number_of_quizzes).to eq(initial_number_of_quizzes + 1)
  end
end

describe "/quizzes" do
  it "creates initial messages when quiz is created", points: 3 do
    # Mock AI::Chat to avoid making actual API calls during tests
    allow(AI::Chat).to receive(:new).and_return(double(
      model: "gpt-4",
      "model=" => nil,
      add: nil,
      generate!: "This is a mocked response from the AI assistant. Question 1: What is 2 + 2?"
    ))
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

    visit "/quizzes"

    fill_in "Topic", with: "Ruby Programming"
    click_on "Create quiz"

    quiz = Quiz.last
    expect(quiz.messages.count).to eq(3),
      "Expected quiz to have 3 initial messages (system, user, and assistant), but found #{quiz.messages.count}"

    expect(quiz.messages.where(role: "system").count).to eq(1),
      "Expected quiz to have 1 system message"

    expect(quiz.messages.where(role: "user").count).to eq(1),
      "Expected quiz to have 1 user message"

    expect(quiz.messages.where(role: "assistant").count).to eq(1),
      "Expected quiz to have 1 assistant message"
  end
end

describe "/quizzes/[ID]" do
  it "displays the quiz topic", points: 1 do
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

    quiz_math = Quiz.new
    quiz_math.topic = "Mathematics"
    quiz_math.user_id = the_user.id
    quiz_math.save

    visit "/quizzes/#{quiz_math.id}"

    expect(page).to have_text(quiz_math.topic),
      "Expected page to display the quiz topic '#{quiz_math.topic}'"
  end
end

describe "/quizzes/[ID]" do
  it "displays all messages for the quiz", points: 2 do
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

    quiz = Quiz.new
    quiz.topic = "Mathematics"
    quiz.user_id = the_user.id
    quiz.save

    message1 = Message.new
    message1.content = "Test the math skills"
    message1.role = "system"
    message1.quiz_id = quiz.id
    message1.save

    message2 = Message.new
    message2.content = "Can you test my math?"
    message2.role = "user"
    message2.quiz_id = quiz.id
    message2.save

    message3 = Message.new
    message3.content = "Sure! Let's start with: What is 2 + 2?"
    message3.role = "assistant"
    message3.quiz_id = quiz.id
    message3.save

    visit "/quizzes/#{quiz.id}"

    expect(page).to have_text(message2.content),
      "Expected page to display the user message"

    expect(page).to have_text(message3.content),
      "Expected page to display the assistant message"
  end
end

describe "/quizzes/[ID]" do
  it "has a form to send a new message", points: 1 do
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

    quiz = Quiz.new
    quiz.topic = "Mathematics"
    quiz.user_id = the_user.id
    quiz.save

    visit "/quizzes/#{quiz.id}"

    expect(page).to have_css("form", minimum: 1),
      "Expected page to have a form for sending messages"
  end
end

describe "/quizzes/[ID]" do
  it "has a 'Delete quiz' link", points: 1 do
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

    quiz = Quiz.new
    quiz.topic = "Mathematics"
    quiz.user_id = the_user.id
    quiz.save

    visit "/quizzes/#{quiz.id}"

    expect(page).to have_tag("a", :text => /Delete quiz/i)
  end
end

describe "/quizzes/[ID]" do
  it "destroys the quiz when the delete link is clicked", points: 1 do
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

    quiz = Quiz.new
    quiz.topic = "Mathematics"
    quiz.user_id = the_user.id
    quiz.save

    visit "/quizzes/#{quiz.id}"

    click_on "Delete quiz"

    final_number_of_quizzes = Quiz.count
    expect(final_number_of_quizzes).to eq(0),
      "Expected quiz to be deleted, but it wasn't."
  end
end
