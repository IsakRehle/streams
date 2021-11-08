# This file is a component in the Rosencrantz Entertainment Conglomerate
# Copyright (C) 2021 Hampus Andreas Niklas Rosencrantz

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

class GetAMovie::Routes::Login < GetAMovie::Routes::BaseRoute
  def login_page(env)
    locale = LANGS[env.get("preferences").as(Preferences).locale]

    referer = get_referer(env, "browse")

    email = env.params.body["email"]?.try &.downcase.byte_slice(0, 254)

    password = env.params.body["password"]?

    if !email
      return error_template(401, "Email is a required field")
    end

    if !password
      return error_template(401, "Password is a required field")
    end

    user = PG_DB.query_one?("SELECT * FROM users WHERE email = $1", email, as: User)

    if user
      if Crypto::Bcrypt::Password.new(user.password.not_nil!).verify(password.byte_slice(0, 55))
	sid = Base64.urlsafe_encode(Random::Secure.random_bytes(32))
	PG_DB.exec("INSERT INTO session_ids VALUES ($1, $2, $3)", sid, email, Time.utc)
      end
    end
  end

  def login(env)
  end

  def signout(env)
  end
end
