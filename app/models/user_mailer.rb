class UserMailer < ActionMailer::Base
  
   def general_email(user, text)  
     recipients user.email 
     from "Eno River Farmers Market Online Ordering"  
     subject "Eno River Farmers Market Online Ordering"  
     sent_on Time.now 
     body[:user] = user
     body[:text] = text 
   end 

end
