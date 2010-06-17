require 'test_helper'

class HaveSentEmailTest < ActiveSupport::TestCase # :nodoc:
  context "an email" do
    setup do
      define_mailer :mailer, [:the_email] do
        def the_email
          if defined?(AbstractController::Rendering)
            mail :from    => "do-not-reply@example.com",
                 :to      => "myself@me.com",
                 :subject => "This is spam",
                 :body    => "Every email is spam."
          else
            from       "do-not-reply@example.com"
            recipients "myself@me.com"
            subject    "This is spam"
            body       "Every email is spam."
          end
        end
      end
      if defined?(AbstractController::Rendering)
        ::ActionMailer::Base.deliveries << Mailer.the_email
      else
        ::ActionMailer::Base.deliveries << Mailer.create_the_email
      end
    end

    should "accept based on the subject" do
      assert_accepts have_sent_email.with_subject(/is spam$/), nil
      assert_rejects have_sent_email.with_subject(/totally safe/), nil
    end

    should "accept based on the sender" do
      assert_accepts have_sent_email.from('do-not-reply@example.com'), nil
      assert_rejects have_sent_email.from('you@example.com'), nil
    end

    should "accept based on the body" do
      assert_accepts have_sent_email.with_body(/is spam\./), nil
      assert_rejects have_sent_email.with_body(/totally safe/), nil
    end

    should "accept baed on the recipienct" do
      assert_accepts have_sent_email.to('myself@me.com'), nil
      assert_rejects have_sent_email.to('you@example.com'), nil
    end

    should "chain" do
      assert_accepts have_sent_email.with_subject(/spam/).from('do-not-reply@example.com').with_body(/spam/).to('myself@me.com'), nil
      assert_rejects have_sent_email.with_subject(/ham/).from('you@example.com').with_body(/ham/).to('them@example.com'), nil
    end
  end
end