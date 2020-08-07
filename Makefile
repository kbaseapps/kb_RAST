SERVICE = kb_rast
SERVICE_CAPS = kb_RAST
SPEC_FILE = kb_RAST.spec
URL = https://kbase.us/services/kb_rast
DIR = $(shell pwd)
LIB_DIR = lib
SCRIPTS_DIR = scripts
TEST_DIR = test
LBIN_DIR = bin
WORK_DIR = /kb/module/work/tmp
EXECUTABLE_SCRIPT_NAME = run_$(SERVICE_CAPS)_async_job.sh
STARTUP_SCRIPT_NAME = start_server.sh
TEST_SCRIPT_NAME = run_tests.sh
KB_RUNTIME ?= /kb/runtime

.PHONY: test

default: compile build-startup-script build-executable-script build-test-script

all: compile build build-startup-script build-executable-script build-test-script

compile:
	kb-sdk compile $(SPEC_FILE) \
		--out $(LIB_DIR) \
		--pysrvname $(SERVICE_CAPS).$(SERVICE_CAPS)Server \
		--pyimplname $(SERVICE_CAPS).$(SERVICE_CAPS)Impl \
		--plpsginame $(SERVICE_CAPS).psgi;
	chmod +x $(SCRIPTS_DIR)/entrypoint.sh;

build-executable-script:
	mkdir -p $(LBIN_DIR)
	echo '#!/bin/bash' > $(LBIN_DIR)/$(EXECUTABLE_SCRIPT_NAME)
	echo 'if [ -L $$0 ] ; then' >> $(LBIN_DIR)/$(EXECUTABLE_SCRIPT_NAME)
	echo 'script_dir=$$(cd "$$(dirname "$$(readlink $$0)")"; pwd -P)' >> $(LBIN_DIR)/$(EXECUTABLE_SCRIPT_NAME)
	echo 'else' >> $(LBIN_DIR)/$(EXECUTABLE_SCRIPT_NAME)
	echo 'script_dir=$$(cd "$$(dirname "$$0")"; pwd -P)' >> $(LBIN_DIR)/$(EXECUTABLE_SCRIPT_NAME)
	echo 'fi' >> $(LBIN_DIR)/$(EXECUTABLE_SCRIPT_NAME)
	echo 'export PERL5LIB=$$script_dir/../$(LIB_DIR):$$PERL5LIB' >> $(LBIN_DIR)/$(EXECUTABLE_SCRIPT_NAME)
	echo 'perl $$script_dir/../$(LIB_DIR)/$(SERVICE_CAPS)/$(SERVICE_CAPS)Server.pm $$1 $$2 $$3' >> $(LBIN_DIR)/$(EXECUTABLE_SCRIPT_NAME)
	chmod +x $(LBIN_DIR)/$(EXECUTABLE_SCRIPT_NAME)

build-startup-script:
	mkdir -p $(LBIN_DIR)
	echo '#!/bin/bash' > $(SCRIPTS_DIR)/$(STARTUP_SCRIPT_NAME)
	echo 'if [ -L $$0 ] ; then' >> $(SCRIPTS_DIR)/$(STARTUP_SCRIPT_NAME)
	echo 'script_dir=$$(cd "$$(dirname "$$(readlink $$0)")"; pwd -P)' >> $(SCRIPTS_DIR)/$(STARTUP_SCRIPT_NAME)
	echo 'else' >> $(SCRIPTS_DIR)/$(STARTUP_SCRIPT_NAME)
	echo 'script_dir=$$(cd "$$(dirname "$$0")"; pwd -P)' >> $(SCRIPTS_DIR)/$(STARTUP_SCRIPT_NAME)
	echo 'fi' >> $(SCRIPTS_DIR)/$(STARTUP_SCRIPT_NAME)
	echo 'export KB_DEPLOYMENT_CONFIG=$$script_dir/../deploy.cfg' >> $(SCRIPTS_DIR)/$(STARTUP_SCRIPT_NAME)
	echo 'export PERL5LIB=$$script_dir/../$(LIB_DIR):$$PERL5LIB' >> $(SCRIPTS_DIR)/$(STARTUP_SCRIPT_NAME)
	echo 'plackup $$script_dir/../$(LIB_DIR)/$(SERVICE_CAPS).psgi' >> $(SCRIPTS_DIR)/$(STARTUP_SCRIPT_NAME)
	chmod +x $(SCRIPTS_DIR)/$(STARTUP_SCRIPT_NAME)

build-test-script:
	echo '#!/bin/bash' > $(TEST_DIR)/$(TEST_SCRIPT_NAME)
	echo 'echo "Running $$0 with args $$@"' >> $(TEST_DIR)/$(TEST_SCRIPT_NAME)
	echo 'if [ -L $$0 ] ; then' >> $(TEST_DIR)/$(TEST_SCRIPT_NAME)
	echo 'test_dir=$$(cd "$$(dirname "$$(readlink $$0)")"; pwd -P) # for symbolic link' >> $(TEST_DIR)/$(TEST_SCRIPT_NAME)
	echo 'else' >> $(TEST_DIR)/$(TEST_SCRIPT_NAME)
	echo 'test_dir=$$(cd "$$(dirname "$$0")"; pwd -P) # for normal file' >> $(TEST_DIR)/$(TEST_SCRIPT_NAME)
	echo 'fi' >> $(TEST_DIR)/$(TEST_SCRIPT_NAME)
	echo 'base_dir=$$(cd $$test_dir && cd .. && pwd);' >> $(TEST_DIR)/$(TEST_SCRIPT_NAME)
	echo 'export KB_DEPLOYMENT_CONFIG=$$base_dir/deploy.cfg' >> $(TEST_DIR)/$(TEST_SCRIPT_NAME)
	echo 'export KB_AUTH_TOKEN=`cat /kb/module/work/token`' >> $(TEST_DIR)/$(TEST_SCRIPT_NAME)
	echo 'export PERL5LIB=$$base_dir/$(LIB_DIR):$$PERL5LIB' >> $(TEST_DIR)/$(TEST_SCRIPT_NAME)
	echo 'cd $$base_dir' >> $(TEST_DIR)/$(TEST_SCRIPT_NAME)
	echo 'prove -I $$test_dir -lvrm $$test_dir' >> $(TEST_DIR)/$(TEST_SCRIPT_NAME)
	chmod +x $(TEST_DIR)/$(TEST_SCRIPT_NAME)


test:
	bash $(TEST_DIR)/$(TEST_SCRIPT_NAME)

clean:
	rm -rfv $(LBIN_DIR)

