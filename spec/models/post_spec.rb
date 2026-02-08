require 'rails_helper'

RSpec.describe Post, type: :model do
  it "can be created with title and body" do
    post = Post.new(title: "Test Title", body: "Test body content")
    expect(post).to be_valid
  end
end
