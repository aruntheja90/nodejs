
BRANCH?=$(shell git rev-parse --abbrev-ref HEAD)

all: test clean

watch: test_deps
	while sleep 1; do \
		find defaults/ handlers/ meta/ tasks/ templates/ tests/vagrant/test.yml \
		| entr -d make test; \
	done

test: vagrant_up

integration_test: clean integration_test_deps vagrant_up clean

test_deps:
	rm -rf tests/vagrant/sansible.nodejs
	ln -s ../.. tests/vagrant/sansible.nodejs

integration_test_deps:
	sed -i.bak \
		-E 's/(.*)version: (.*)/\1version: origin\/$(BRANCH)/' \
		tests/vagrant/integration_requirements.yml
	rm -rf tests/vagrant/sansible.*
	ansible-galaxy install -p tests/vagrant -r tests/vagrant/integration_requirements.yml
	mv tests/vagrant/integration_requirements.yml.bak tests/vagrant/integration_requirements.yml

vagrant_up:
	cd tests/vagrant && vagrant up --no-provision
	cd tests/vagrant && vagrant provision

vagrant_ssh:
	cd tests/vagrant && vagrant up
	cd tests/vagrant && vagrant ssh

clean:
	rm -rf tests/vagrant/sansible.*
	cd tests/vagrant && vagrant destroy
