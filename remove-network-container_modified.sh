me=`basename $0`
if [ $# -lt 1 ]; then
  echo "Usage: $me CONTAINERNUM"
  echo "   CONTAINERNUM    The name of a running container for which the public networking container should be removed"
  exit 1
fi

name=$1
if [[ $(docker ps | grep $name) ]]; then
  if [[ $(docker ps | grep mtree_test-$name) ]]; then
    x=$(docker exec mtree_test-$name dhclient -r eth1)
    x=$(docker stop mtree_test-$name)
    x=$(docker rm mtree_test-$name)
  else
    echo "Container $name has no public networking container"
  fi
else
  echo "No container with name $name"
  exit 2
fi
