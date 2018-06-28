-include custom.mk

default: metal-k8s

METAL_K8S_DIR ?= metal-k8s
METAL_K8S_MAKEFILE := $(METAL_K8S_DIR)/Makefile
SHELL_ENV = .shell-env
VENV = $(SHELL_ENV)/metal-k8s
VENV_BIN = $(VENV)/bin
REQUIREMENTS_INSTALLED := $(SHELL_ENV)/.requirements_installed

CONFIG_FILE := group_vars/all/global_config.yml
ANSIBLE_PLAYBOOK ?= $(METAL_K8S_DIR)/$(VENV_BIN)/ansible-playbook
METAL_K8S_VENV := $(METAL_K8S_DIR)/$(SHELL_ENV)/.additional_dependency
METAL_K8S_VENV_BIN := $(METAL_K8S_DIR)/$(VENV_BIN)

EDITOR ?= vi
SHELL := bash
SHELLRC := .kubeshellrc
ANSIBLE_ARGS ?= $(AA)

ANSIBLE_CALL := $(ANSIBLE_PLAYBOOK) $(ANSIBLE_ARGS) $@

$(CONFIG_FILE):
	cp $@.sample $@

$(METAL_K8S_MAKEFILE):
	git submodule init -- $(dir $@)
	git submodule update -- $(dir $@)

$(METAL_K8S_VENV): |$(METAL_K8S_MAKEFILE)
	@make -C $(METAL_K8S_DIR) $(REQUIREMENTS_INSTALLED)
	@$(METAL_K8S_VENV_BIN)/pip install -r requirements.txt
	@touch $@

.PHONY: config
config: | $(METAL_K8S_VENV) $(CONFIG_FILE)
	@TEMP_FILE=`mktemp /tmp/supteal_ansible.XXXXXX`; \
	mv $${TEMP_FILE} $${TEMP_FILE}.yml; \
	cp $(CONFIG_FILE) $${TEMP_FILE}.yml; \
	${EDITOR} $${TEMP_FILE}.yml; \
	$(METAL_K8S_VENV_BIN)/python -c "import yaml; yaml.load(open('$${TEMP_FILE}.yml'))" && \
	mv $${TEMP_FILE}.yml $(CONFIG_FILE)

.PHONY: metal-k8s
metal-k8s: |$(METAL_K8S_VENV)  ## Install kubernetes on AWS
	@$(ANSIBLE_CALL) 00-site.yml

shell:  $(METAL_K8S_VENV)
	make -C $(METAL_K8S_DIR) shell
