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
require 'pony'
require 'redcarpet'

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


  def generate_create_email(event,data)
    if data["ref_type"] == "branch"
        reponame = data["repository"]["name"]
        subject = "New branch "+data["ref"]+" created in "+reponame
        body = "<h2>New branch "+data["ref"]+" created in "+reponame+"</h2>"
        body = body+"Branch "+data["ref"]+" created by "+data["sender"]["login"]
        send_mail(subject,body)
    end
  end


  def generate_delete_email(event,data)
    if data["ref_type"] == "branch"
        reponame = data["repository"]["name"]
        subject = "Branch "+data["ref"]+" deleted in "+reponame
        body = "<h2>Branch "+data["ref"]+" deleted in "+reponame+"</h2>"
        body = body+"Branch "+data["ref"]+" deleted by "+data["sender"]["login"]
        send_mail(subject,body)
    end
  end


  def generate_pull_email(event,data)
  
      if data["action"] == "opened"
          generate_open_pull_email(event,data)
      elsif data["action"] == "closed"
          generate_close_pull_email(event,data)
      elsif data["action"] == "reopened"
          generate_reopen_pull_email(event,data)
      end
  
  end
  
  
  def generate_open_pull_email(event,data)
    renderer    = Redcarpet::Render::HTML.new(prettify:true,hard_wrap:true)
    markdown    = Redcarpet::Markdown.new(renderer,tables:true,autolink:true,no_intra_emphasis:true)
    reponame    = data["repository"]["name"]
    pr_num      = data["pull_request"]["number"].to_s
    pr_link     = data["pull_request"]["html_url"]
    df_link     = data["pull_request"]["diff_url"]
    pr_form     = "<a href=\""+pr_link+"\">#"+pr_num+"</a>"
    patch_link  = data["pull_request"]["patch_url"]
    subject     = "New pull request (#"+pr_num+") opened on "+reponame
    body        = "<h2>New pull request (#"+pr_form+") opened on "+reponame+"</h2>"
    body = body + "<h3>"+data["pull_request"]["title"]+"</h3>"
    body = body + "<a href=\""+pr_link+"\">View the pull request</a><br>"
    body = body + "<a href=\""+df_link+"\">View the code diff</a><br>"
    body = body + "<a href=\""+patch_link+"\">Obtain a patch file</a><br>"
    body = body + "<br>Opened by: <a href=\""+data["pull_request"]["user"]["html_url"]+"\">"+\
                  data["pull_request"]["user"]["login"]+"</a><br><br>"
    body = body + "Merge changes from <b>"+data["pull_request"]["head"]["ref"]+"</b> into <b>"+\
                  data["pull_request"]["base"]["ref"]+"</b><br>"
    pr_description = markdown.render(data["pull_request"]["body"])
    body = body + "<h3>Description</h3>"+pr_description
    send_mail(subject,body)
  end
  
  
  def generate_close_pull_email(event,data)
    reponame    = data["repository"]["name"]
    pr_num      = data["pull_request"]["number"].to_s
    pr_link     = data["pull_request"]["html_url"]
    df_link     = data["pull_request"]["diff_url"]
    patch_link  = data["pull_request"]["patch_url"]
    pr_form     = "<a href=\""+pr_link+"\">#"+pr_num+"</a>"
    
    if data["pull_request"]["merged"]
        user    = data["pull_request"]["merged_by"]["login"]
        subject = "Pull request (#"+pr_num+") merged on "+reponame
        body    = "Pull request ("+pr_form+") merged and closed on "+reponame+" by "+user
        body    = body + "<br><b>Title:</b> "+data["pull_request"]["title"]
        send_mail(subject,body)
    else
        user    = data["pull_request"]["user"]["login"]
        subject = "Pull request (#"+pr_num+") closed on "+reponame
        body    = "Pull request ("+pr_form+") closed without merge on "+reponame+" by "+user
        body = body + "<br><b>Title:</b> "+data["pull_request"]["title"]
        send_mail(subject,body)
    end
  
  end
  
  
  def generate_reopen_pull_email(event,data)
    reponame    = data["repository"]["name"]
    pr_num      = data["pull_request"]["number"].to_s
    pr_link     = data["pull_request"]["html_url"]
    df_link     = data["pull_request"]["diff_url"]
    patch_link  = data["pull_request"]["patch_url"]
    pr_form     = "<a href=\""+pr_link+"\">#"+pr_num+"</a>"
    user        = data["pull_request"]["user"]["login"]
    subject     = "Pull request (#"+pr_num+") reopened on "+reponame
    body        = "Pull request ("+pr_form+") reopened on "+reponame+" by "+user+"<br>"
    body        = body + "<br><b>Title:</b> "+data["pull_request"]["title"]+"<br><br>"
    body        = body + "<a href=\""+pr_link+"\">View the pull request</a><br>"
    body        = body + "<a href=\""+df_link+"\">View the code diff</a><br>"
    body        = body + "<a href=\""+patch_link+"\">Obtain a patch file</a><br>"
    send_mail(subject,body)
  end
  
  
  def generate_issues_comment_email(event,data)
    renderer = Redcarpet::Render::HTML.new(prettify:true,hard_wrap:true)
    markdown = Redcarpet::Markdown.new(renderer,tables:true,autolink:true,no_intra_emphasis:true)
    reponame = data["repository"]["name"]
    num = data["issue"]["number"].to_s
    user = data["comment"]["user"]["login"]
    comment = data["comment"]["body"]

    unless data["issue"]["pull_request"].nil?
        subject = "Comment on pull request #"+num+" in "+reponame
        body = "<h2>Comment on pull request #"+num+" in "+reponame+"</h2>"
    else
        subject = "Comment on issue #"+num+" in "+reponame
        body = "<h2>Comment on issue #"+num+" in "+reponame+"</h2>"
    end
    body = body + "<b>User:</b> "+user+"<br><br>"
    body = body + "<h3>Comment</h3>"+markdown.render(comment)
    send_mail(subject,body)

  end


  def generate_issues_email(event,data)
    if data["action"]=="opened"
        generate_issues_opened_email(event,data)
    elsif data["action"]=="closed"
        generate_issues_closed_email(event,data)
    elsif data["action"]=="reopened"
        generate_issues_reopened_email(event,data)
    end
  end


  def generate_issues_opened_email(event,data)
    renderer = Redcarpet::Render::HTML.new(prettify:true,hard_wrap:true)
    markdown = Redcarpet::Markdown.new(renderer,tables:true,autolink:true,no_intra_emphasis:true)
    reponame = data["repository"]["name"]
    title=data["issue"]["title"]
    comment=data["issue"]["comment"]
    num=data["issue"]["number"].to_s
    url=data["issue"]["html_url"]
    issue_form="<a href=\""+url+"\">#"+num+"</a>"

    subject="New issue (#"+num+") opened in "+reponame
    body        = "<h2>New issue ("+issue_form+") opened on "+reponame+"</h2>"
    body = body + "<b>Opened by: </b><a href=\""+data["issue"]["user"]["html_url"]+"\">"+\
                  data["issue"]["user"]["login"]+"</a><br>"
    body = body + "<h3>Subject</h3>"+data["issue"]["title"]
    description = markdown.render(data["issue"]["body"])
    body = body + "<h3>Description</h3>"+description

    send_mail(subject,body)

  end


  def generate_issues_closed_email(event,data)
    reponame = data["repository"]["name"]
    user=data["issue"]["user"]["login"]
    title=data["issue"]["title"]
    comment=data["issue"]["comment"]
    num=data["issue"]["number"].to_s
    url=data["issue"]["html_url"]
    issue_form="<a href=\""+url+"\">#"+num+"</a>"
    subject="Issue (#"+num+") closed in "+reponame
    body = "<b>Title:</b> "+title
    body = body+"<br><br>Issue ("+issue_form+") closed on "+reponame+" by "+user
  
    send_mail(subject,body)

  end 

  
  def generate_issues_reopened_email(event,data)
    reponame = data["repository"]["name"]
    user=data["issue"]["user"]["login"]
    title=data["issue"]["title"]
    comment=data["issue"]["comment"]
    num=data["issue"]["number"].to_s
    url=data["issue"]["html_url"]
    issue_form="<a href=\""+url+"\">#"+num+"</a>"
    subject="Issue (#"+num+") reopened in "+reponame
    body = "<b>Title:</b> "+title
    body = body+"<br><br>Issue ("+issue_form+") reopened on "+reponame+" by "+user
  
    send_mail(subject,body)

  end 


  def generate_push_email(event,data)

     #...We capture the delete event
     #   elsewhere, but github sends
     #   two events 
      unless data["deleted"].nil?
        if data["deleted"]
            return
        end
      end
  
      added = Array.new
      removed = Array.new
      modified = Array.new

      reponame = data["repository"]["name"]
  
      branch = data["ref"].split("/")[2]
      subject = "Commits pushed to "+reponame+"/"+branch
  
      body = "<h2>Commits pushed to "+reponame+"/"+branch+"</h2>"+\
             "<a href=\""+data["compare"]+"\">Click here to view change set</a><br><br>
             <h3>Commit Summary</h3><ul>"
  
      data["commits"].each do |child|
          body = body + "<li><b>Commit Hash:</b> <a href=\""+child["url"]+"\">"+child["id"][0..6]+"</a>" + \
                "<ul>" +
                  "<li> <b>Author:</b> "+child["author"]["username"]+"</li>"+\
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
  

end
