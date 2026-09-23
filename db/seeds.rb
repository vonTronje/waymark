if Rails.env.local?
  [
    { name: "Player One",  email_address: "player.one@test.de",  password: "playerone" },
    { name: "Player Two",  email_address: "player.two@test.de",  password: "playertwo" },
    { name: "Game Master", email_address: "game.master@test.de", password: "gamemaster" }
  ].each do |attributes|
    User.find_or_initialize_by(email_address: attributes[:email_address]).update!(attributes)
  end
end
