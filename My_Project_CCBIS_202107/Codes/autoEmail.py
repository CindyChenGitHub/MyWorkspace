#=============================================================================
#=== Install and import necessary modules
#=============================================================================
from import_neccessary_modules import *
modules = ['os', 'email', 'smtplib', 'time']
for module in modules:
    import_neccessary_modules(module)
#=============================================
#=== Set Dependicy
#=============================================
#to create pdf report
#from io import BytesIO
#from reportlab.pdfgen import canvas
#from django.http import HttpResponse
#to automate email
import os, email, smtplib, time
from email import encoders
from email.mime.base import MIMEBase
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
#=============================================
#=== Send Email
#=============================================
# assign key email aspects to variables for easier future editing
subject = "Daily ETL Report - CCBIS"
body = "This is an email with the desired report attached"
sender_email = "yue.cyb@gmail.com"
receiver_email = "cindyyuechen@icloud.com"
my_path = r"C:\MyDataFiles\Data_CCBIS_202107"
fileName = time.strftime("%Y%m%d") + '_CCBIS.log'
file = os.path.join(my_path, fileName)
password = "yuecyb2021"
# Create the email head (sender, receiver, and subject)
email = MIMEMultipart()
email["From"] = sender_email
email["To"] = receiver_email 
email["Subject"] = subject
# Add body and attachment to email
email.attach(MIMEText(body, "plain"))
attach_file = open(file, "rb") # open the file
report = MIMEBase("application", "octate-stream")
report.set_payload((attach_file).read())
encoders.encode_base64(report)
#add report header with the file name
report.add_header("Content-Decomposition", "attachment", filename = file)
email.attach(report)
#Create SMTP session for sending the mail
session = smtplib.SMTP('smtp.gmail.com', 587) #use gmail with port
session.starttls() #enable security
session.login(sender_email, password) #login with mail_id and password
text = email.as_string()
session.sendmail(sender_email, receiver_email, text)
session.quit()
print('Mail Sent')