.PHONY: install dry-run packages lint test

install:        ## Crée les liens symboliques vers $HOME
	./install.sh

dry-run:        ## Simule install.sh sans rien modifier
	./install.sh --dry-run

packages:       ## Installe les paquets (apt, snap, node, rust, go, github)
	./bootstrap/install-packages.sh

lint:           ## bash -n + shellcheck (POSIX pour profile/00/10)
	bash -n install.sh bootstrap/install-packages.sh bash/bashrc bash/rc.d/*.sh
	shellcheck -s sh bash/profile bash/rc.d/00-env.sh bash/rc.d/10-tools.sh
	shellcheck install.sh bootstrap/install-packages.sh bash/bashrc bash/rc.d/[2-9]*.sh

test:           ## Installation à blanc dans un conteneur Ubuntu 26.04
	./bootstrap/test-in-docker.sh
