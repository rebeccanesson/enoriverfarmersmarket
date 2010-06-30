class UserMailer < ActionMailer::Base
  
   def general_email(user, text)  
     recipients user.email 
     from "Eno River Farmers Market Online Ordering"  
     subject "Eno River Farmers Market Online Ordering"  
     sent_on Time.now 
     body[:user] = user
     body[:text] = text 
   end 
   
   def category_request(admin_user, requesting_user, text)
     recipients admin_user.email
     from "#{requesting_user.name}"
     subject "New Category Request"
     sent_on Time.now
     body[:admin_user] = admin_user
     body[:requesting_user] = requesting_user
     body[:text] = text
   end

end
