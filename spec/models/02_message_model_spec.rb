require "rails_helper"

describe "Message" do
  it "validates presence of content", points: 1 do
    message = Message.new
    message.role = "user"
    message.valid?
    expect(message.errors[:content]).to include("can't be blank"),
      "Expected Message to validate presence of content, but it didn't."
  end
end

describe "Message" do
  it "validates presence of role", points: 1 do
    message = Message.new
    message.content = "Test message"
    message.valid?
    expect(message.errors[:role]).to include("can't be blank"),
      "Expected Message to validate presence of role, but it didn't."
  end
end

describe "Message" do
  it "belongs to a quiz", points: 1 do
    message = Message.new
    expect(message).to respond_to(:quiz),
      "Expected Message to have a quiz association, but it didn't."
  end
end
