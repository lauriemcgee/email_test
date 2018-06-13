defmodule EmailTest.EmailTest do
  use ExUnit.Case
  import Bamboo.Email

  test "creating an email" do
    email =
      EmailTest.Email.welcome_email

      assert email.to == "ckoch@ncsasports.org"
      assert email.from == "recruitinghelp@ncsasports.org"
      assert email.subject == "Reminder"
      assert email.html_body == "<h1>TEST</h1<p>test</p>"
      assert email.text_body == " What is text body"
  end

  test "dynamic content" do
    email = EmailTest.Email.welcome_email(%{subject: "Welcome Call Reminder", to: "lmcgee@ncsasports.org", from: "coachlaurie@ncsasports.org", html_body: "body", text_body: "welcome call"})

    assert email.to == "lmcgee@ncsasports.org"
    assert email.from == "coachlaurie@ncsasports.org"
    assert email.subject == "Welcome Call Reminder"
    assert email.html_body == "body"
    assert email.text_body == "welcome call"
  end

  test "set mandrill template" do
    email = EmailTest.Email.welcome_email(%{subject: "Welcome Call Reminder", to: "lmcgee@ncsasports.org", from: "coachlaurie@ncsasports.org", html_body: "body", text_body: "welcome call", template: "some mandrill template"})

    assert email.to == "lmcgee@ncsasports.org"
    assert email.from == "coachlaurie@ncsasports.org"
    assert email.subject == "Welcome Call Reminder"
    assert email.html_body == "body"
    assert email.text_body == "welcome call"
    assert email.private[:template_name] == "some mandrill template"
  end

  test "sends to multiple emails" do
    email = EmailTest.Email.welcome_email([%{subject: "Welcome Call Reminder", to: "lmcgee@ncsasports.org", from: "coachlaurie@ncsasports.org", html_body: "body", text_body: "welcome call", template: "welcome-call-reminder-2018-06-13", template_content: %{
        to: "lmcgee@ncsasports.org",
        client_first_name: "Laurie",
        cancel_session_url: "http://www.ncsasports.org/lauries_url",
        start_time_string_with_day: "Timestamp1",
        meeting_type: "Welcome Call"
      }}, %{subject: "Welcome Call Reminder", to: "ckoch@ncsasports.org", from: "alsockoch@ncsasports.org", html_body: "body", text_body: "welcome call", template: "welcome-call-reminder-2018-06-13", template_content: %{
        to: "ckoch@ncsasports.org",
        client_first_name: "Christian",
        cancel_session_url: "http://www.ncsasports.org/christians_url",
        start_time_string_with_day: "Timestamp2",
        meeting_type: "Welcome Call"
      }}])

    IO.inspect(email)

  end

  test "set mandrill template variables" do
    template_vars = [
      %{name: "start_time_string", content: "Timestamp1"},
      %{name: "meeting_type", content: "Welcome Call"},
      %{name: "first_name", content: "Christian"},
      %{name: "cancel_url", content: "http://www.ncsasports.org/christians_url"}
    ]
    map_to_convert = %{
      first_name: "Christian",
      cancel_url: "http://www.ncsasports.org/christians_url",
      start_time_string: "Timestamp1",
      meeting_type: "Welcome Call"
    }

    email = EmailTest.Email.welcome_email(%{subject: "Welcome Call Reminder", to: ["lmcgee@ncsasports.org", "ckoch@ncsasports.org"], from: "coachlaurie@ncsasports.org", html_body: "body", text_body: "welcome call", template: "welcome-call-reminder-2018-06-13", template_content: map_to_convert})
    assert email.to == ["lmcgee@ncsasports.org", "ckoch@ncsasports.org"]
    assert email.from == "coachlaurie@ncsasports.org"
    assert email.subject == "Welcome Call Reminder"
    assert email.html_body == "body"
    assert email.text_body == "welcome call"
    assert email.private[:template_name] == "welcome-call-reminder-2018-06-13"
    assert email.private[:message_params]["global_merge_vars"] == template_vars
  end

  test "convert to mandrill structure" do
    list_to_convert = %{
      to: "email1@ncsasports.org",
      first_name: "Christian",
      cancel_url: "http://www.ncsasports.org/christians_url",
      start_time_string: "Timestamp1"
    }

    assert EmailTest.Email.mandrill_merge_vars(list_to_convert) ==
      %{
        rcpt: "email1@ncsasports.org",
        vars: [
          %{content: "Timestamp1", name: "start_time_string"},
          %{content: "Christian", name: "first_name"},
          %{
            content: "http://www.ncsasports.org/christians_url",
            name: "cancel_url"
          }
        ]
      }
  end

  test "convert list of maps to mandrill structure" do
    template_vars = [
      %{name: "start_time_string", content: "Timestamp1"},
      %{name: "meeting_type", content: "Welcome Call"},
      %{name: "first_name", content: "Christian"},
      %{name: "cancel_url", content: "http://www.ncsasports.org/christians_url"}
    ]
    map_to_convert = %{
      first_name: "Christian",
      cancel_url: "http://www.ncsasports.org/christians_url",
      start_time_string: "Timestamp1",
      meeting_type: "Welcome Call"
    }

    assert EmailTest.Email.map_to_list(map_to_convert) == template_vars

  end
end

