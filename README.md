# ECS Services dashboard

This just add four graph for each ECS service into common dashboard. The meaning is to have quick over view of load of services without explicitly finding each metric for it. Dashboard is updated every five minutes

# Nifty zip file

I am sorry for that binary blob. The problem is that for AWS Lambda you can not call `pip install Jinja2` of whatever, you just have to import it as folder into your lambda function. That's why the zip file. I would add all of it as folder to github, but that would mean creating redundancy and in future obsolete module.
  