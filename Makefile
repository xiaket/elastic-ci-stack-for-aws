.PHONY: build-ami create-stack update-stack toc

STACK_NAME ?= buildkite
SHELL=/bin/bash -o pipefail
TEMPLATE=stacks/buildkite-elastic.yml

build-ami: config.json
	cd packer/; packer build buildkite-ami.json | tee ../packer.output
	jq '.[] | select(.ParameterKey=="ImageId").ParameterValue = $$image' \
		--arg image "$$(grep -Eo 'us-east-1: (ami-.+)' packer.output | cut -d' ' -f2)" \
		config.json > config.json

config.json:
	test -s config.json || $(error Please create a config.json file)

extra_tags.json:
	echo "{}" > extra_tags.json

create-stack: config.json extra_tags.json
	aws cloudformation create-stack \
	--output text \
	--stack-name $(STACK_NAME) \
	--disable-rollback \
	--template-body "file://$(PWD)/$(TEMPLATE)" \
	--capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
	--parameters "$$(cat config.json)" \
	--tags "$$(cat extra_tags.json)"

validate:
	aws cloudformation validate-template \
	--output table \
	--template-body "file://$(PWD)/$(TEMPLATE)"

update-stack: config.json
	aws cloudformation update-stack \
	--output text \
	--stack-name $(STACK_NAME) \
	--template-body "file://$(PWD)/$(TEMPLATE)" \
	--capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
	--parameters "$$(cat config.json)"

toc:
	docker run -it --rm -v "$$(pwd):/app" node:slim \
		bash -c "npm install -g markdown-toc && cd /app && markdown-toc -i Readme.md"
