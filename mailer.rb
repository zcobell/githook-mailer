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
class Mailer
  def send(event_type,data)
  
    #...Configuration for which events to send
    send_create = true
    send_delete = true
    send_issues_comments = true
    send_issues = true
    send_milestones = false
    send_pullrequests = true
    send_push = true
    send_release = true
  
    case event_type
        #...Created repository, branch, or tag
        when "create"
          if send_create
            generate_create_email(event_type,data)
          end
        #...Deleted branch or tag
        when "delete"
          if send_delete
            generate_delete_email(event_type,data)
          end
        #...Issue is commented on, edited, or deleted
        when "issue_comment"
          if send_issues_comments
            generate_issues_comment_email(event_type,data)
          end
        #...Issue is assigned, unassigned, labeled, unlabeled
        #   opened, edited, milestoned, demilestoned, closed,
        #   or reopened
        when "issues"
          if send_issues
            generate_issues_email(event_type,data)
          end
        #...Triggered when a milestone is created, closed, opened,
        #   edited, or deleted
        when "milestone"
          if send_milestones
            generate_milestones_email(event_type,data)
          end
        #...Triggered when assigned, unassigned, labeled, unlabeled,
        #   opened, edited, closed, reopened, or synchronized. Also
        #   when review requested or review request is removed
        when "pull_request"
          if send_pullrequests
            generate_pull_email(event_type,data)
          end
        #...Triggered by branch pushes and repository tag pushes
        when "push"
          if send_push
            generate_push_email(event_type,data)
          end
        #...Triggered when a release is published
        when "release"
          if send_release
            generate_release_email(event_type,data)
          end
    end
  
  end
  
  
  def generate_pull_email(event,data)
  
      if data["action"] == "opened"
          generate_open_pull_email(event,data)
      elsif data["action"] == "closed"
          generate_close_pull_email(event,data)
      elsif data["action"] == "reopened"
          generate_reopen_pull_email(event,data)
      elsif data["action"] == "edited"
          generate_edited_pull_email(event,data)
      end
  
  end
  
  
  def generate_open_pull_email(event,data)
  
  end
  
  
  def generate_close_pull_email(event,data)
  
  end
  
  
  def generate_reopen_pull_email(event,data)
  
  end
  
  
  def generate_edited_pull_email(event,data)
  
  end
  
  
  def generate_push_email(event,data)
  
      added = Array.new
      removed = Array.new
      modified = Array.new
  
      branch = data["ref"].split("/")[2]
      subject = "Commits pushed to "+ENV["REPO_NAME"]+"/"+branch
  
      body = "<h2>Commits pushed to "+ENV["REPO_NAME"]+"/"+branch+"</h2>"+\
             "<a href=\""+data["compare"]+"\">Click here to view change set</a><br><br>
             <h3>Commit Summary</h3><ul>"
  
      data["commits"].each do |child|
          body = body + "<li><b>Commit Hash:</b> <a href=\""+child["url"]+"\">"+child["id"][0..6]+"</a>" + \
                "<ul>" +
                  "<li> <b>Author:</b> "+child["author"]["name"]+"</li>"+\
                  "<li> <b>Description:</b> "+child["message"]+"</li>"+\
                "</ul>"
          unless child["added"].nil?
              child["added"].each do |add|
                  unless added.include? add
                      added.push(add)
                  end
              end
          end
          unless child["removed"].nil?
              child["removed"].each do |add|
                  unless removed.include? add
                      removed.push(add)
                  end
              end
          end
          unless child["modified"].nil?
              child["modified"].each do |add|
                  unless modified.include? add
                      modified.push(add)
                  end
              end
          end
      end
  
      body = body + "</ul>"
      body = body + "<h3>File Changes</h3><ul>"
  
      unless added.nil?
          added.each do |child|
              body = body + "<li><b>A</b> " + child + "</li>"
          end
      end
  
      unless removed.nil?
          removed.each do |child|
              body = body + "<li><b>D</b> " + child + "</li>"
          end
      end
  
      unless modified.nil?
          modified.each do |child|
              body = body + "<li><b>M</b> " + child + "</li>"
          end
      end
  
      body = body + "</ul>"
  
      send_mail(subject,body)
  
  end
  
  def send_mail(subject,body)
  
    if ENV['EMAIL_SSL'] == 1
      use_ssl = true
    else
      use_ssl = false
    end
  
    Pony.mail :to      => ENV['EMAIL_TO'],
              :from    => ENV['EMAIL_FROM'],
              :subject =>  subject,
              :headers => { 'Content-Type' => 'text/html' },
              :body    =>  body,
              :via     => :smtp,
              :via_options => {
                  :address                => ENV['EMAIL_SERVER'],
                  :port                   => ENV['EMAIL_PORT'],
                  :user_name              => ENV['EMAIL_USER'],
                  :password               => ENV['EMAIL_PASSWORD'],
                  :authentication         => :plain,
                  :enable_starttls_auto   => use_ssl
                }
  end

end
