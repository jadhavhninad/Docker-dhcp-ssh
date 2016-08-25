# This script creates a networking container

me=`basename $0`
function usage {
  echo "Usage: $me CONTAINERNUM IFDEV"
  echo "   IFDEV            The name of the network device on the host machine through which network traffic should be bridged"
  echo "   CONTAINENUM      Random number assigned to the container"
  exit 1
}
if [ $# -lt 2 ]; then
  usage
fi

# The argument is the name of the network device on the host that
# should be bridged into the networking container
cname=$1
ifdev=$2

# create the script for running inside the networking container
mkdir -p /tmp/docker_networking/

# name of the network container
name="mtree_test-$cname"

# name of the script
script="$RANDOM$$$$$$.sh"

# create the script
# wait for eth1 to be created
echo "/opt/bin/pipework --wait -i eth1" >> /tmp/docker_networking/$script

# acquire ip from dhcp server
echo "dhclient -v eth1" >> /tmp/docker_networking/$script

# lookup the ip of the private_server in the docker network
echo "ip=\$(echo \$(cat /etc/hosts | grep private_server) | cut -d ' ' -f 1)" >> /tmp/docker_networking/$script
for port in $ports; do
  echo "creating iptables route for port $port"
  echo "iptables -t nat -A PREROUTING -p tcp --dport $port -j DNAT --to-destination \$ip:$port" >> /tmp/docker_networking/$script
  echo "iptables -t nat -A PREROUTING -p udp --dport $port -j DNAT --to-destination \$ip:$port" >> /tmp/docker_networking/$script
done
echo "iptables -t nat -A POSTROUTING -j MASQUERADE" >> /tmp/docker_networking/$script
echo "bash" >> /tmp/docker_networking/$script

# make it executable, writable
chmod a+wrx /tmp/docker_networking/$script

# start the network container executing the script
id=$(docker run --privileged --name $name -v /tmp/docker_networking:/scripts/ -dti 10.110.142.178:5000/test_image:latest bash /scripts/$script)
echo "containerid=$id"

# create a new network device eth1 inside the networking container
# and bridge it to the host network device
sudo /opt/bin/pipework $ifdev $id 0/0

# wait for the public ip to be bound to the networking container
while [ 1 ]; do
  pubip=$(docker exec $name ifconfig eth1 | grep "inet addr:" | awk '{print $2}' | awk -F: '{print $2}');
  if [[ $pubip ]]; then
    echo "ip=$pubip"
    break;
  else
    echo "waiting on IP from DHCP"
    sleep 5
  fi
done

# container is running, remove the script
rm /tmp/docker_networking/$script

#Restarting the network service
#This is not required if it has already been done in docker file

#docker exec $name sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config
#docker exec $name service sshd restart
