require 'rails_helper'

RSpec.describe Answer, type: :model do
  let(:user)   { create :confirmed_user }
  let(:answer) { create :answer, author: user }

  describe "relations" do
    it { should belong_to(:author).class_name('User') }
    it { should belong_to(:question) }
  end

  describe "validations" do
    it { should validate_presence_of(:body) }
    it { should validate_presence_of(:question_id) }
    it { should validate_presence_of(:author_id) }
    it { should validate_length_of(:body).is_at_least(2) }

    describe "#question_not_expired" do 
      let(:expired_question)  { create :question, created_at: Date.today - 31.days}
      let(:question)          { create :question }

      it "validates question not older than 30" do 
        answer = Answer.new(question: expired_question)
        answer.validate
        expect(answer.errors[:question_expired].size).to eq(1)
      end

      it "does not return an error if the question is not expired" do 
        answer = Answer.new(question: question)
        answer.validate
        expect(answer.errors[:question_expired].size).to eq(0)
      end
    end
  end

  describe "recent scope" do
    it "orders by created_at date in descending order" do
      a1 = create :answer, author: user, created_at: 1.day.ago
      a2 = create :answer, author: user

      expect(Answer.recent).to eq([a2, a1])
    end
  end

  describe "#votes" do
    it "returns total votes" do
      answer.add_evaluation :votes, 5, user

      expect(answer.votes).to eql(5)
      expect(answer.reputation_for(:votes)).to eql(5.0)
    end
  end

  describe "#upvote_by" do
    it "changes votes count positively" do
      expect { answer.upvote_by(user) }.to change { answer.votes }.from(0).to(1)
    end
  end

  describe "#upvoted_by?" do
    it "checks if answer upvoted by user" do
      expect(answer.upvoted_by?(user)).to be false

      answer.add_evaluation :votes, Votable::UPVOTE_VALUE, user
      expect(answer.upvoted_by?(user)).to be true
    end
  end

  describe "#downvote_by" do
    it "changes votes count negatively" do
      expect { answer.downvote_by(user) }.to change { answer.votes }.from(0).to(-1)
    end
  end

  describe "#downvoted_by?" do
    it "checks if answer downvoted by user" do
      expect(answer.downvoted_by?(user)).to be false

      answer.add_evaluation :votes, Votable::DOWNVOTE_VALUE, user
      expect(answer.downvoted_by?(user)).to be true
    end
  end
end
