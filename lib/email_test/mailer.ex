defmodule EmailTest.Mailer do
  use Bamboo.Mailer, otp_app: :email_test
end

# Define your emails
defmodule EmailTest.Email do
  import Bamboo.Email
  import Bamboo.MandrillHelper

  def welcome_email(options) when is_list(options) do
    Enum.reduce(options, [], fn(email_info, acc) -> List.insert_at(acc, -1, welcome_email(email_info)) end)
  end

  def welcome_email(options \\ %{}) do
    template_content = map_to_list(Map.get(options, :template_content, %{}))
    new_email
    |> to(Map.get(options, :to, "ckoch@ncsasports.org"))
    |> from(Map.get(options, :from, "recruitinghelp@ncsasports.org"))
    |> subject(Map.get(options, :subject, "Reminder"))
    |> html_body(Map.get(options, :html_body, "<h1>TEST</h1<p>test</p>"))
    |> text_body(Map.get(options, :text_body, " What is text body"))
    |> template(Map.get(options, :template))
    |> put_param("global_merge_vars", template_content)
    |> put_param("merge_language", "handlebars")
    # |> put_merge_vars(Map.get(options, :template_content, []), fn(x) -> x end)
  end

  def map_to_list(map_to_convert) do
    Enum.reduce(map_to_convert, [], fn({k, v}, acc) -> IO.puts("#{k} #{v}")
      k = if is_atom(k), do: Atom.to_string(k), else: k
      List.insert_at(acc, 0, %{
        name: k,
        content: v
      })
    end)
  end

  def mandrill_merge_vars(map_to_merge) when is_list(map_to_merge) do
    Enum.reduce(map_to_merge, [], fn(x, acc) -> List.insert_at(acc, -1, mandrill_merge_vars(x)) end)
  end

  def mandrill_merge_vars(map_to_merge) do
    {email, map} = Map.pop(map_to_merge, :to)
    %{
      rcpt: email,
      vars: map_to_list(map)
    }
  end
end
