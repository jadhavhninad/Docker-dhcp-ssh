# Docker-dhcp-ssh
Assigning IP to docker containers via DHCP so that they are accessible individually using SSH.

# Use Case
In our test environment, we had to use multiple virtual machines for testing nfs related test, or to trigger automation test cases. 
So in order to reduce their use and to make the process automated by integrating with jenkins, we are using docker containers. This
required the  docker container to have a DHCP IP as well as access via SSH.

# Requirement
