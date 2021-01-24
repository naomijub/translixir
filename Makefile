CRUXDB_ERROR=$(shell docker ps -aq --filter name=CruxDB --filter status=paused --filter status=exited --filter status=dead)

CRUXDB_OK=$(shell docker ps -aq --filter name=CruxDB --filter status=running)

crux:
ifneq ($(strip $(CRUXDB_ERROR)),)
	docker rm -f $(CRUXDB_ERROR)
endif

ifeq ($(strip $(CRUXDB_OK)),)
	docker run -d -p 3000:3000 --name CruxDB juxt/crux-standalone:20.09-1.11.0
endif

all: deps compile protocols

get-deps:
	rm -f mix.lock
	mix deps.get

deps: get-deps
	mix deps.compile

compile:
	mix compile

protocols:
	mix compile.protocols

clean-deps:
	mix deps.clean --all
	rm -rf deps

clean: clean-deps
	mix clean

test: compile
	mix test

docs:
	mix docs

format:
	mix format

lint: format
	mix credo --strict

outdated:
	mix hex.outdated

spec:
	mix dialyzer --format dialyxir

publish: docs
	mix hex.publish
	mix hex.publish docs
