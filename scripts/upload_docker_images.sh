#!/bin/bash

# DO NOT INVOKE DIRECTLY. Use Makefile target upload-docker-images

branch=${1}

echo "Generate and upload docker images for branch ${branch}"

# sveltos-manager
echo "processing sveltos-manager"
rm -rf tmp; mkdir tmp; cd tmp
git clone git@github.com:projectsveltos/sveltos-manager.git
cd sveltos-manager
git checkout ${branch}
make docker-build
docker push gianlucam76/sveltos-manager-amd64:${branch}  
cd ../../; rm -rf tmp

# classifier
echo "processing classifier"
rm -rf tmp; mkdir tmp; cd tmp
git clone git@github.com:projectsveltos/classifier.git
cd classifier
git checkout ${branch}
make docker-build
docker push gianlucam76/classifier-amd64:${branch}
cd ../../; rm -rf tmp

# classifier-agent
echo "processing classifier-agent"
rm -rf tmp; mkdir tmp; cd tmp
git clone git@github.com:projectsveltos/classifier-agent.git
cd classifier-agent
git checkout ${branch}
make docker-build
docker push gianlucam76/classifier-agent-amd64:${branch}
cd ../../; rm -rf tmp

# access-manager
echo "processing access-manager"
rm -rf tmp; mkdir tmp; cd tmp
git clone git@github.com:projectsveltos/access-manager.git
cd access-manager
git checkout ${branch}
make docker-build
docker push gianlucam76/access-manager-amd64:${branch}  
cd ../../; rm -rf tmp

# sveltoscluster-manager
echo "processing sveltoscluster-manager"
rm -rf tmp; mkdir tmp; cd tmp
git clone git@github.com:projectsveltos/sveltoscluster-manager.git
cd sveltoscluster-manager
git checkout ${branch}
make docker-build
docker push gianlucam76/sveltoscluster-manager-amd64:${branch}  
cd ../../; rm -rf tmp