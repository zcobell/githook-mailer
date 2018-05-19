#-------------------------------GPL-------------------------------------#
#
# githook-mailer - Send github webhooks anywhere
# Copyright (C) 2018  Zach Cobell
#
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
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#-----------------------------------------------------------------------#
ruby '2.5.1'

# define our source to loook for gems
source "http://rubygems.org/"

# declare the sinatra dependency
gem "sinatra" 

# setup our test group and require rspec
group :test do
  gem "rspec"
end

gem 'activesupport', '>=1.4'

# require a relative gem version
gem "i18n", "~> 0.4.1"

# Pony email
gem "pony"
