# set the concourse target default to dev
CONCOURSE ?= ud

# set the pxf-protocol-extension default branch to current branch
BRANCH ?= $(shell git rev-parse --abbrev-ref HEAD)

# set YOUR_TAG to current release tag for longevity pipeline
YOUR_TAG ?= $(shell git describe --tags --abbrev=0)

SHELL                        = /bin/bash
BUILD_PIPELINE_NAME         ?= pxf-build
DEV_BUILD_PIPELINE_NAME     ?= dev-$(USER)-$(BRANCH)
PR_BUILD_PIPELINE_NAME      ?= pxf_pr_pipeline
CERTIFICATION_PIPELINE_NAME ?= pxf-certification
CLOUDBUILD_PIPELINE_NAME    ?= cloudbuild
DEV_CLOUDBUILD_PIPELINE_NAME ?= dev-cloudbuild-$(USER)-$(BRANCH)
PERF_PIPELINE_NAME          ?= pxf_perf-$(SCALE)g-RHEL$(REDHAT_MAJOR_VERSION)
GPDB_ARTIFACTS_PIPELINE_NAME ?= gpdb-artifacts
NUM_GPDB5_VERSIONS          ?= 10
NUM_GPDB6_VERSIONS          ?= 10
NUM_GPDB7_VERSIONS          ?= 10
REDHAT_MAJOR_VERSION        ?= 7
FLY_CMD                     ?= fly
CHECK_CREDS                 ?= true
TEMPLATE_CMD                 = ./template_tool
FLY_OPTION_NON-INTERACTIVE   =
NOTIFY                      ?= true
# below are dev-build specific vars
MULTINODE_EL7               ?= false
MULTINODE_EL8               ?= false
MULTINODE_EL9               ?= false
MULTINODE_NO_IMPERSONATION  ?= false
JDK11                       ?= false
CDH                         ?= false
HDP2                        ?= false
HDP3                        ?= false
S3                          ?= false
ABFSS                       ?= false
WASBS                       ?= false
GS                          ?= false
MINIO                       ?= false
OEL7                        ?= false
FILE                        ?= false
GP7_CLI                     ?= false
LOAD                        ?= false
# used to quickly modify the docker image tag being pulled ONLY in the dev_build_pipeline
PXF_DEV_IMAGE_TAG           ?= latest
RELEASE_IMAGE_TAG           ?= latest

SET_PIPELINE := set-pipeline
ifeq ($(CHECK_CREDS), true)
SET_PIPELINE += --check-creds
endif

.PHONY: release main certification dev-release dev pr cloudbuild dev-cloudbuild longevity gpdb-artifacts
release: set-release-pipeline
main: set-main-pipeline
certification: set-certification-pipeline
dev-release: set-dev-release-pipeline
dev: set-dev-build-pipeline
pr: set-pr-build-pipeline
cloudbuild: set-cloudbuild-pipeline
dev-cloudbuild: set-dev-cloudbuild-pipeline
longevity: set-longevity-pipeline
gpdb-artifacts: set-gpdb-artifacts-pipeline

# ============================= BUILD PIPELINE TARGETS =============================
.PHONY: set-release-pipeline
set-release-pipeline:
ifndef RELEASE_BRANCH
	$(error RELEASE_BRANCH is not set, please set a release branch)
else
RELEASE_IMAGE_TAG = release-$(word 2, $(subst -, , $(RELEASE_BRANCH)))
set-release-pipeline: SHIPIT_REGEX="$(RELEASE_BRANCH)/greenplum-pxf-(.*).txt"
set-release-pipeline: NOTIFY=true
set-release-pipeline: PIPELINE_NAME=$(BUILD_PIPELINE_NAME)-$(RELEASE_BRANCH)
set-release-pipeline: ENVIRONMENT=prod
set-release-pipeline: BUCKET_PREFIX=prod
set-release-pipeline: IMAGE_TAG=${RELEASE_IMAGE_TAG}
set-release-pipeline: set-build-pipeline-base
endif

.PHONY: set-main-pipeline
set-main-pipeline: SHIPIT_REGEX=noop
set-main-pipeline: NOTIFY=true
set-main-pipeline: PIPELINE_NAME=$(BUILD_PIPELINE_NAME)
set-main-pipeline: RELEASE_BRANCH=main
set-main-pipeline: ENVIRONMENT=prod
set-main-pipeline: BUCKET_PREFIX=prod
set-main-pipeline: IMAGE_TAG=latest
set-main-pipeline: set-build-pipeline-base

.PHONY: set-dev-release-pipeline
set-dev-release-pipeline: SHIPIT_REGEX="$(USER)-$(BRANCH)/greenplum-pxf-(.*).txt"
set-dev-release-pipeline: PIPELINE_NAME=$(DEV_BUILD_PIPELINE_NAME)
set-dev-release-pipeline: RELEASE_BRANCH=$(BRANCH)
set-dev-release-pipeline: ENVIRONMENT=dev
set-dev-release-pipeline: EXTRA_VARS=--var=ud/pxf/dev/git-remote-ssh-url=noop
set-dev-release-pipeline: BUCKET_PREFIX=dev/$(USER)-$(BRANCH)
set-dev-release-pipeline: IMAGE_TAG=$(PXF_DEV_IMAGE_TAG)
set-dev-release-pipeline: set-build-pipeline-base

.PHONY: set-build-pipeline-base
set-build-pipeline-base:
	@PIPELINE_FILE=$$(mktemp) && \
	$(TEMPLATE_CMD) --template build_pipeline-tpl.yml --vars \
		environment=$(ENVIRONMENT) \
		gchat_notification=$(NOTIFY) \
		user=$(USER) \
		num_gpdb5_versions=$(NUM_GPDB5_VERSIONS) \
		num_gpdb6_versions=$(NUM_GPDB6_VERSIONS) \
		num_gpdb7_versions=$(NUM_GPDB7_VERSIONS) >"$${PIPELINE_FILE}" && \
	$(FLY_CMD) --target=$(CONCOURSE) \
		$(SET_PIPELINE) \
		--pipeline=$(PIPELINE_NAME) \
		--config "$${PIPELINE_FILE}" \
		--load-vars-from=$(HOME)/workspace/pxf/concourse/settings/pxf-multinode-params.yml \
		--var=pxf-git-branch=$(RELEASE_BRANCH) \
		--var=pxf-build-bucket-prefix=$(BUCKET_PREFIX) \
		--var=gpdb-pxf-dev-image-tag=$(IMAGE_TAG) \
		--var=shipit-regex=$(SHIPIT_REGEX) \
		$(EXTRA_VARS) \
		${FLY_OPTION_NON-INTERACTIVE} || echo "Generated yaml has errors: check $${PIPELINE_FILE}"

	@echo using the following command to unpause the pipeline:
	@echo -e "\t$(FLY_CMD) -t ${CONCOURSE} unpause-pipeline --pipeline ${BUILD_PIPELINE_NAME}"

.PHONY: set-dev-build-pipeline
set-dev-build-pipeline:
	@PIPELINE_FILE=$$(mktemp) && \
	$(TEMPLATE_CMD) --template dev_build_pipeline-tpl.yml --vars \
		gchat_notification=$(NOTIFY) \
		multinode_el7=$(MULTINODE_EL7) \
		multinode_el8=$(MULTINODE_EL8) \
		multinode_el9=$(MULTINODE_EL9) \
		multinode_no_impersonation=$(MULTINODE_NO_IMPERSONATION) \
		jdk11=$(JDK11) \
		cdh=$(CDH) \
		hdp2=$(HDP2) \
		hdp3=$(HDP3) \
		file=$(FILE) \
		s3=$(S3) \
		abfss=$(ABFSS) \
		wasbs=$(WASBS) \
		gs=$(GS) \
		minio=$(MINIO) \
		oel7=$(OEL7) \
		gp7_cli=$(GP7_CLI) \
		load=$(LOAD) \
		dev_pipeline=true \
		user=$(USER) \
		branch=$(BRANCH) \
		num_gpdb5_versions=1 \
		num_gpdb6_versions=1 \
		num_gpdb7_versions=1 >"$${PIPELINE_FILE}" && \
	$(FLY_CMD) --target=$(CONCOURSE) \
		$(SET_PIPELINE) \
		--pipeline=$(DEV_BUILD_PIPELINE_NAME) \
		--config "$${PIPELINE_FILE}" \
		--load-vars-from=$(HOME)/workspace/pxf/concourse/settings/pxf-multinode-params.yml \
		--var=pxf-git-branch=${BRANCH} \
		--var=pxf-build-bucket-prefix=dev/$(USER)-$(BRANCH) \
		--var=gpdb-pxf-dev-image-tag=$(PXF_DEV_IMAGE_TAG) \
		--var=shipit-regex=$(SHIPIT_REGEX) \
		${FLY_OPTION_NON-INTERACTIVE} || echo "Generated yaml has errors: check $${PIPELINE_FILE}"

	@echo using the following command to unpause the pipeline:
	@echo -e "\t$(FLY_CMD) -t ${CONCOURSE} unpause-pipeline --pipeline ${DEV_BUILD_PIPELINE_NAME}"

.PHONY: set-hadoop-cluster-cleaner
set-hadoop-cluster-cleaner:
	@PIPELINE_FILE=$$(mktemp) && \
	$(TEMPLATE_CMD) --template hadoop-cluster-cleaner-tpl.yml --vars \
		gchat_notification=true >"$${PIPELINE_FILE}" && \
	$(FLY_CMD) --target=$(CONCOURSE) \
		$(SET_PIPELINE) \
		--pipeline=hadoop-cluster-cleaner \
		--config "$${PIPELINE_FILE}" \
		--var=pxf-git-branch=main \
		${FLY_OPTIONS_NON-INTERACTIVE} || echo "Generated yaml has errors: check $${PIPELINE_FILE}"

	@echo "using the following command to unpause the pipeline"
	@echo -e "\t$(FLY_CMD) -t $(CONCOURSE) unpause-pipeline --pipeline hadoop-cluster-cleaner"

.PHONY: set-pr-build-pipeline
set-pr-build-pipeline:
	@PIPELINE_FILE=$$(mktemp) && \
	$(TEMPLATE_CMD) --template pr_pipeline-tpl.yml --vars \
		gchat_notification=false \
		pr_pipeline=true \
		num_gpdb5_versions=1 \
		num_gpdb6_versions=1 \
		num_gpdb7_versions=1 >"$${PIPELINE_FILE}" && \
	$(FLY_CMD) --target=$(CONCOURSE) \
		$(SET_PIPELINE) \
		--pipeline=$(PR_BUILD_PIPELINE_NAME) \
		--config "$${PIPELINE_FILE}" \
		${FLY_OPTION_NON-INTERACTIVE} || echo "Generated yaml has errors: check $${PIPELINE_FILE}"

	@echo using the following command to unpause the pipeline:
	@echo -e "\t$(FLY_CMD) -t ${CONCOURSE} unpause-pipeline --pipeline ${PR_BUILD_PIPELINE_NAME}"


# ============================= FORWARD COMPATIBILITY PIPELINE TARGETS =============================

.PHONY: set-certification-pipeline
set-certification-pipeline:
	@PIPELINE_FILE=$$(mktemp) && \
	$(TEMPLATE_CMD) --template certification_pipeline-tpl.yml --vars \
		gchat_notification=true >"$${PIPELINE_FILE}" && \
	$(FLY_CMD) --target=$(CONCOURSE) \
		$(SET_PIPELINE) \
		--pipeline=$(CERTIFICATION_PIPELINE_NAME) \
		--config "$${PIPELINE_FILE}" \
		--var=pxf-git-branch=${BRANCH} \
		--var=gpdb-pxf-dev-image-tag=latest \
		${FLY_OPTION_NON-INTERACTIVE} || echo "Generated yaml has errors: check $${PIPELINE_FILE}"

	@echo using the following command to unpause the pipeline:
	@echo -e "\t$(FLY_CMD) -t ${CONCOURSE} unpause-pipeline --pipeline ${CERTIFICATION_PIPELINE_NAME}"

# ============================= HELPER PIPELINE TARGETS =============================

.PHONY: set-cloudbuild-pipeline
set-cloudbuild-pipeline: PXF_GIT_BRANCH=main
set-cloudbuild-pipeline: GCP_IMAGE_TAG=latest
set-cloudbuild-pipeline: PIPELINE_NAME=$(CLOUDBUILD_PIPELINE_NAME)
set-cloudbuild-pipeline: set-cloudbuild-pipeline-base

.PHONY: set-dev-cloudbuild-pipeline
set-dev-cloudbuild-pipeline: PXF_GIT_BRANCH=$(BRANCH)
set-dev-cloudbuild-pipeline: GCP_IMAGE_TAG=$(PXF_DEV_IMAGE_TAG)
set-dev-cloudbuild-pipeline: PIPELINE_NAME=$(DEV_CLOUDBUILD_PIPELINE_NAME)
set-dev-cloudbuild-pipeline: set-cloudbuild-pipeline-base

.PHONY: set-cloudbuild-pipeline-base
set-cloudbuild-pipeline-base:
	$(FLY_CMD) --target=$(CONCOURSE) \
		$(SET_PIPELINE) \
		--config $(HOME)/workspace/pxf/concourse/pipelines/cloudbuild_pipeline.yml \
		--var pxf-git-branch=$(PXF_GIT_BRANCH) \
		--var gcp-image-tag=$(GCP_IMAGE_TAG) \
		--pipeline $(PIPELINE_NAME) \
		${FLY_OPTION_NON-INTERACTIVE} || echo "pipelines/cloudbuild_pipeline.yml has errors"

.PHONY: set-gpdb-artifacts-pipeline
set-gpdb-artifacts-pipeline: generate-gpdb-artifacts-pipeline
	$(FLY_CMD) --target=$(CONCOURSE) \
		$(SET_PIPELINE) \
		--pipeline=${GPDB_ARTIFACTS_PIPELINE_NAME} \
		--config ./generated/get_gpdb_artifacts.yml \
		--var pxf-git-branch=$(BRANCH) \
		${FLY_OPTION_NON-INTERACTIVE}

	@echo using the following command to unpause the pipeline:
	@echo -e "\t$(FLY_CMD) -t ${CONCOURSE} unpause-pipeline --pipeline ${GPDB_ARTIFACTS_PIPELINE_NAME}"

.PHONY: generate-gpdb-artifacts-pipeline
generate-gpdb-artifacts-pipeline:
	mkdir -p generated
	$(TEMPLATE_CMD) --template get_gpdb_artifacts-tpl.yml --vars \
		num_gpdb5_versions=$(NUM_GPDB5_VERSIONS) \
		num_gpdb6_versions=$(NUM_GPDB6_VERSIONS) \
		num_gpdb7_versions=$(NUM_GPDB7_VERSIONS)>./generated/get_gpdb_artifacts.yml

.PHONY: singlecluster
singlecluster:
	$(FLY_CMD) --target=$(CONCOURSE) \
		$(SET_PIPELINE) \
		--pipeline=pxf-singlecluster \
		--config ~/workspace/pxf/concourse/pipelines/singlecluster-pipeline.yml \
		--var pxf-git-branch=main \
		${FLY_OPTIONS_NON-INTERACTIVE} || echo "pipelines/singlecluster-pipeline.yml has errors"

	@echo "using the following command to unpause the pipeline"
	@echo -e "\t$(FLY_CMD) -t $(CONCOURSE) unpause-pipeline --pipeline pxf-singlecluster"

# ============================= PERFORMANCE PIPELINE TARGETS =============================

.PHONY: perf
perf:
	@if [ -z '$(SCALE)' ]; then \
		echo 'Specify the SCALE for the test (i.e make SCALE=10 perf). Allowed SCALE values are 10, 50, 500'; \
		exit 1; \
	fi
	@PIPELINE_FILE=$$(mktemp) && \
	$(TEMPLATE_CMD) --template perf_pipeline-tpl.yml --vars \
		redhat_major_version=$(REDHAT_MAJOR_VERSION) >"$${PIPELINE_FILE}" && \
	$(FLY_CMD) --target=$(CONCOURSE) \
		$(SET_PIPELINE) \
		--config "$${PIPELINE_FILE}" \
		--load-vars-from=$(HOME)/workspace/pxf/concourse/settings/perf-settings-$(SCALE)g.yml \
		--var pxf-git-branch=$(BRANCH) \
		--pipeline $(PERF_PIPELINE_NAME) \
		${FLY_OPTION_NON-INTERACTIVE}

.PHONY: data-gen-1g
data-gen-1g:
	@if ! [ -d ~/workspace/gp-performance-testing ]; then \
		echo 'Please clone the gp-performance-testing repository to your workspace.'; \
		exit 1; \
	fi
	make -C ~/workspace/gp-performance-testing \
		FLY_TARGET=ud \
		data-gen-pxf-parquet-tpc-h-1g-6X \
		INPUT_FILE=data-gen-6x-pxf.yml

.PHONY: query-execution-parquet
query-execution-parquet-1g:
	@if ! [ -d ~/workspace/gp-performance-testing ]; then \
		echo 'Please clone the gp-performance-testing repository to your workspace.'; \
		exit 1; \
	fi
	make -C ~/workspace/gp-performance-testing \
		FLY_TARGET=ud \
		query-execution-pxf-parquet-tpc-h-1g-6X \
		INPUT_FILE=ccp-provision-from-release-pxf.yml

# ============================= LONGEVITY PIPELINE TARGETS =============================
.PHONY: set-longevity-pipeline
set-longevity-pipeline:
	$(FLY_CMD) --target=$(CONCOURSE) \
		$(SET_PIPELINE) \
		--pipeline=dev:longevity_$(YOUR_TAG)_6X_STABLE \
		--config pipelines/longevity_pipeline.yml \
		--load-vars-from=settings/pxf-multinode-params.yml \
		--var=folder-prefix=dev/pivotal \
		--var=test-env=dev \
		--var=icw_green_bucket=gpdb5-assert-concourse-builds \
		--var=gcs-bucket-intermediates=pivotal-gpdb-concourse-resources-intermediates-prod \
		--var=gcs-bucket-resources-prod=pivotal-gpdb-concourse-resources-prod \
		--var=gpdb-branch=6X_STABLE \
		--var=pgport=6000 \
		--var=pxf-tag=$(YOUR_TAG)
## ----------------------------------------------------------------------
## List explicit rules
## ----------------------------------------------------------------------

.PHONY: list
list:
	@sh -c "$(MAKE) -p no_targets__ 2>/dev/null | \
	awk -F':' '/^[a-zA-Z0-9][^\$$#\/\\t=]*:([^=]|$$)/ {split(\$$1,A,/ /);for(i in A)print A[i]}' | \
	grep -v Makefile | \
	grep -v '%' | \
	grep -v '__\$$' | \
	sort"

## ----------------------------------------------------------------------
## Lint targets
## ----------------------------------------------------------------------
.PHONY: check
check:
	$(MAKE) lint

.PHONY: lint
lint:
	$(MAKE) shfmt shellcheck yamllint

.PHONY: shfmt
shfmt:
	docker run --rm -v ${CURDIR}:/code mvdan/shfmt:v2.6.4 -d /code

.PHONY: shellcheck
shellcheck:
	docker run --rm -v ${CURDIR}:/code mvdan/shfmt:v2.6.4 -f /code | xargs docker run --rm -v ${CURDIR}:/code koalaman/shellcheck:v0.7.0 -e SC1090,SC1091

.PHONY: yamllint
yamllint:
	docker run --rm -v ${CURDIR}:/code cytopia/yamllint /code -c /code/.yamllint
