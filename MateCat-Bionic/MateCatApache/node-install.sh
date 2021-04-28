#!/bin/bash

NODE_VERSION=v14.16.1

# echo "Node Linux Installer by www.github.com/taaem"
echo "Need Root for installing NodeJS"
sh -c 'echo "Got Root!"' 

echo "Get Latest Version Number..."
{
wget --output-document=node-updater.html https://nodejs.org/dist/${NODE_VERSION}/

ARCH=$(uname -m)

if [ $ARCH = x86_64 ]
then
	grep -o '>node-v.*-linux-x64.tar.gz' node-updater.html > node-cache.txt 2>&1

	ARCH_VERSION=$(grep -o 'node-v.*-linux-x64.tar.gz' node-cache.txt)
else
	grep -o '>node-v.*-linux-x86.tar.gz' node-updater.html > node-cache.txt 2>&1
	
	ARCH_VERSION=$(grep -o 'node-v.*-linux-x86.tar.gz' node-cache.txt)
fi
rm ./node-cache.txt
rm ./node-updater.html
} # &> /dev/null

echo "Done"

DIR=$( cd "$( dirname $0 )" && pwd )

echo "Downloading latest stable Version $ARCH_VERSION..."
{
echo "wget https://nodejs.org/dist/${NODE_VERSION}/${ARCH_VERSION} -O $DIR/$ARCH_VERSION"
wget https://nodejs.org/dist/${NODE_VERSION}/${ARCH_VERSION} -O $DIR/$ARCH_VERSION
} # &> /dev/null

echo "Done"

echo "Installing..."
cd /usr/local && tar --strip-components 1 -xzf $DIR/$ARCH_VERSION

rm $DIR/$ARCH_VERSION

echo "Finished installing!"
