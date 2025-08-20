require "rails_helper"

describe "Creating a message" do
  it "generates an AI response", points: 3 do
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

    quiz = Quiz.new
    quiz.topic = "Mathematics"
    quiz.user_id = the_user.id
    quiz.save

    initial_message_count = quiz.messages.count

    visit "/quizzes/#{quiz.id}"

    fill_in "Content", with: "My answer is 4"
    click_on "Add message"

    quiz.reload
    final_message_count = quiz.messages.count

    # Should have added 2 messages: user message and AI response
    expect(final_message_count).to eq(initial_message_count + 2),
      "Expected to add 2 messages (user and assistant), but added #{final_message_count - initial_message_count}"

    # Check that the last message is from the assistant
    last_message = quiz.messages.order(:created_at).last
    expect(last_message.role).to eq("assistant"),
      "Expected last message to be from assistant, but was from #{last_message.role}"
  end
end

describe "Updating a message" do
  it "deletes subsequent messages and generates new AI response", points: 3 do
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
    message3.content = "What is 2 + 2?"
    message3.role = "assistant"
    message3.quiz_id = quiz.id
    message3.save

    message4 = Message.new
    message4.content = "The answer is 4"
    message4.role = "user"
    message4.quiz_id = quiz.id
    message4.save

    message5 = Message.new
    message5.content = "Correct! What is 3 + 3?"
    message5.role = "assistant"
    message5.quiz_id = quiz.id
    message5.save

    visit "/users/sign_in"

    within(:css, "form") do
      fill_in "Email", with: the_user.email
      fill_in "Password", with: the_user.password
      click_button "Log in"
    end

    # Update message4
    visit "/messages/#{message4.id}"

    fill_in "Content", with: "Actually, I think it's 5"
    click_on "Update message"

    quiz.reload

    # message5 should be deleted, and a new assistant message should be created
    expect(Message.exists?(message5.id)).to be(false),
      "Expected subsequent message to be deleted after update"

    # Should have a new assistant message
    last_message = quiz.messages.order(:created_at).last
    expect(last_message.role).to eq("assistant"),
      "Expected new assistant message after update"
  end
end

describe "Deleting a message" do
  it "deletes the message and all subsequent messages", points: 2 do
    the_user = User.new
    the_user.username = "testuser"
    the_user.email = "claire@example.com"
    the_user.password = "password"
    the_user.save

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
    message3.content = "What is 2 + 2?"
    message3.role = "assistant"
    message3.quiz_id = quiz.id
    message3.save

    message4 = Message.new
    message4.content = "The answer is 4"
    message4.role = "user"
    message4.quiz_id = quiz.id
    message4.save

    message5 = Message.new
    message5.content = "Correct! What is 3 + 3?"
    message5.role = "assistant"
    message5.quiz_id = quiz.id
    message5.save

    visit "/users/sign_in"

    within(:css, "form") do
      fill_in "Email", with: the_user.email
      fill_in "Password", with: the_user.password
      click_button "Log in"
    end

    # Delete message3 directly via its show page
    visit "/messages/#{message3.id}"

    click_on "Delete message"

    # After deletion, we're redirected to the quiz page
    # but the quiz should still exist
    quiz = Quiz.find(quiz.id)

    # message3, message4, and message5 should be deleted
    expect(Message.exists?(message3.id)).to be(false),
      "Expected message3 to be deleted"

    expect(Message.exists?(message4.id)).to be(false),
      "Expected subsequent message4 to be deleted"

    expect(Message.exists?(message5.id)).to be(false),
      "Expected subsequent message5 to be deleted"

    # message1 and message2 should still exist
    expect(Message.exists?(message1.id)).to be(true),
      "Expected earlier message1 to still exist"

    expect(Message.exists?(message2.id)).to be(true),
      "Expected earlier message2 to still exist"
  end
end
