stages=${*:-1 2 3}
# build.sh is to build docker image from within MacBook
. setting.sh
if [ -x ~/bin/arad-de ] ; then
    . ~/bin/arad-de
fi
AWS_ACCOUNT=925741509387
ARTIFACTORY=arad-micro-svcs-docker-virtual.jfrog.io.pge.com/
ECR=$AWS_ACCOUNT.dkr.ecr.us-west-2.amazonaws.com
TAG=$ECR/kube-docker-jupyter:$PROJECT-$VERSION

if grep -q 1 <<< "$stages" ; then
    echo "Rebuild distribution"
    rm $HOME/dist/*
    (cd $HOME/git/dca-foundry-jupyter && pip wheel -w $HOME/dist .)
    (cd $HOME/git/dca-aws-jupyter && pip wheel -w $HOME/dist .)
    rm $HOME/dist/*macos*
    rm -rf dist
    mkdir -p dist
    cp $HOME/dist/* dist
fi
if grep -q 3 <<< "$stages" ; then
    echo "Stage 3: Build docker image"
    fill-template -D RUNTIME_ENV=$ENV Dockerfile.template
    docker build . -t $PROJECT:$VERSION --build-arg ARTIFACTORY=$ARTIFACTORY --build-arg ENV=$ENV
fi
if grep -q 4 <<< "$stages" ; then
    echo "Stage 4: Tag and push docker image"
    aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin $ECR >/dev/null
    docker tag $PROJECT:$VERSION $TAG
    echo "Push $TAG"
    docker push $TAG
fi
if grep -q 5 <<< "$stages" ; then
    echo "Stage 5: Deply kubernetes cronjob"
    fill-template -D RUNTIME_ENV=$ENV -D PROJECT=$PROJECT -D VERSION=$VERSION -D TAG=$TAG cron.yaml.template
    kubectl -n tline-dev apply -f cron.yaml
fi


