# Docker-dhcp-ssh
Assigning IP to docker containers via DHCP so that they are accessible individually using SSH.

## Use Case
In our test environment, we had to use multiple virtual machines for testing nfs related test, or to trigger automation test cases. 
So in order to reduce their use and to make the process automated by integrating with jenkins, we are using docker containers. This
required the  docker container to have a DHCP IP as well as access via SSH.

## How does it work?

1. Run the network container and pass it the generated iptables script.
2. Create a network bridge from the network interface of the host to the interface inside the container.
3. Wait for the container to come up on a public IP address.

Next to setting up iptables routing inside the container, the generated script also tries to acquire an IP address using DHCP. For this to succeed it is very important that a DHCP server is available on the network that is bridged into the container.

## Usage

### Create containers
'create-network-container.sh **CONTAINERNUM IFDEV**'

The script takes two paramaters. A random number to assign to the default container name, and the network interface of the host that must be bridged into the network container. To find out the name of the network interface on your host use ifconfig.

### Remove containers

'remove-network-container.sh **CONTAINERUM**'

Releases the IP assigned to the container and then stops and removes it.

## Example 

'''
[root@localhost bin]# ./create-network-container_modified.sh 019 eno50336512
containerid=f87618181ca1f802241d19a468b8c45a6f66ed42f734935178eb18183b2d5602
waiting on IP from DHCP
waiting on IP from DHCP
ip=10.98.95.138
Stopping sshd: [FAILED]
Generating SSH2 RSA host key: [  OK  ]
Generating SSH1 RSA host key: [  OK  ]
Generating SSH2 DSA host key: [  OK  ]
Starting sshd: [  OK  ]
[root@localhost bin]# docker ps
CONTAINER ID        IMAGE                                                                  COMMAND                  CREATED              STATUS              PORTS                        NAMES
f87618181ca1        10.110.142.178:5000/test_image:latest                                  "bash /scripts/366326"   About a minute ago Up About a minute   22/tcp                       test-019
1de8e30fe705        10.110.142.178:5000/test_image:latest                                  "bash /scripts/228282"   2 minutes ago        Up 2 minutes        22/tcp                       test-018

'''

## Installation

### Requirements

To bridge the network interface I rely on https://github.com/jpetazzo/pipework, install this first. It is assumed that pipework is available as /opt/bin/pipework. The scripts are modified for my use case. The original implementation is 'Creating docker network containers ' - https://github.com/jeroenpeeters/docker-network-containers

The network interface on the Docker host should allow for promiscuous mode: ip link set dev ETH_DEV_NAME promisc on
When running on a virtualized environment (VMWare, VirtualBox, etc) the virtual tap devices should be set to allow promiscuous mode as well.
Install the Docker Network Container scripts on each Docker host:

git clone https://github.com/jeroenpeeters/docker-network-containers.git /tmp/networking-container
cp /tmp/networking-container/create-network-container_modified.sh /opt/bin/
cp /tmp/networking-container/remove-network-container_modified.sh /opt/bin/
chmod +x /opt/bin/create-network-container_modified.sh /opt/bin/remove-network-container_modified.sh
