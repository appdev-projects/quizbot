require "rails_helper"

describe "User" do
  it "has a column called 'encrypted_password' of type 'string'", points: 1 do
    new_user = User.new
    expect(new_user.attributes).to include("encrypted_password"),
      "Expected to have a column called 'encrypted_password', but didn't find one."
    expect(User.column_for_attribute("encrypted_password").type).to be(:string),
      "Expected column to be of type 'string' but wasn't."
  end
end

describe "User" do
  it "does not have a password column", points: 1 do
    expect(User.columns.map(&:name)).to_not include("password"),
      "Expected User to NOT have a column called 'password', but found one."
  end
end

describe "User" do
  it "has a column called 'username' of type 'string'", points: 1 do
    new_user = User.new
    expect(new_user.attributes).to include("username"),
      "Expected to have a column called 'username', but didn't find one."
    expect(User.column_for_attribute("username").type).to be(:string),
      "Expected column to be of type 'string' but wasn't."
  end
end

describe "User" do
  it "validates presence of username", points: 1 do
    user = User.new
    user.email = "test@example.com"
    user.password = "password"
    user.valid?
    expect(user.errors[:username]).to include("can't be blank"),
      "Expected User to validate presence of username, but it didn't."
  end
end

describe "User" do
  it "validates uniqueness of username", points: 1 do
    user1 = User.new
    user1.username = "testuser"
    user1.email = "test1@example.com"
    user1.password = "password"
    user1.save

    user2 = User.new
    user2.username = "testuser"
    user2.email = "test2@example.com"
    user2.password = "password"
    user2.valid?

    expect(user2.errors[:username]).to include("has already been taken"),
      "Expected User to validate uniqueness of username, but it didn't."
  end
end

describe "User" do
  it "has many quizzes", points: 1 do
    user = User.new
    expect(user).to respond_to(:quizzes),
      "Expected User to have a quizzes association, but it didn't."
  end
end

describe "User" do
  it "downcases and strips username before saving", points: 1 do
    user = User.new
    user.username = "  TestUser  "
    user.email = "test@example.com"
    user.password = "password"
    user.save

    expect(user.username).to eq("testuser"),
      "Expected username to be downcased and stripped to 'testuser', but got '#{user.username}'."
  end
end
