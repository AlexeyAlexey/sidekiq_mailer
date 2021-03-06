module Sidekiq
  module RedmineMailer
  	module BeforeFilter
  	  class Mailer
	    def issue_add(args)
	      args.map{|a| a.is_a?(Array) ? (a.map(&:id))  : (a.id)}
	    end

		def document_added(args)
		  [args.first.id, User.current.id]
		end
	  end
    end
  end
end

class Sidekiq::RedmineMailer::AfterFilter::Mailer
  def issue_add(params)
    #sleep 1
    i = 0
	issue_ = nil
	issue_id, to_users, cc_users = *params
	while issue_.nil? and i < 10
	  (sleep 0.3) if i > 0
	  i += 1
	  issue_ = Issue.find_by_id(issue_id)
	end

	to_users_ = to_users.map{|user_id| User.find_by_id(user_id)}
	cc_users_ = cc_users.map{|user_id| User.find_by_id(user_id)}
	params_ = []
	params_ << issue_
	params_ << to_users_
	params_ << cc_users_
	params_
  end

  def document_added(params)
    document_id, user_current_id = *params
    document = Document.find_by_id(document_id)
    User.current = User.find_by_id(user_current_id)

	params = []
	params << document
  end
end