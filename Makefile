# GIT_TAG = $(shell git describe --abbrev=0 --tags)
GIT_TAG = $(shell git describe --tags `git rev-list --tags --max-count=1`)
BUILD_JS_DIR = dist/js
PROTO_PATH = protobuf


.PHONY: setup-protobuf
setup-protobuf:
	wget https://github.com/protocolbuffers/protobuf/releases/download/v$(PROTOC_VERSION)/protoc-$(PROTOC_VERSION)-linux-x86_64.zip -O /tmp/protoc.zip
	unzip /tmp/protoc.zip -d /tmp/protoc
	sudo mv /tmp/protoc/bin/protoc /usr/local/bin/protoc
	sudo chmod +x /usr/local/bin/protoc

	wget https://github.com/grpc/grpc-web/releases/download/$(PROTOC_GEN_GRPC_WEB_VERSION)/protoc-gen-grpc-web-$(PROTOC_GEN_GRPC_WEB_VERSION)-linux-x86_64 -O /tmp/protoc-gen-grpc-web
	sudo mv /tmp/protoc-gen-grpc-web /usr/local/bin/protoc-gen-grpc-web
	sudo chmod +x /usr/local/bin/protoc-gen-grpc-web

.PHONY: resolve-git
resolve-git:
	git fetch --all --tags

.PHONY: clean
clean:
	rm -rf $(BUILD_JS_DIR)

# Requires protoc and protoc-gen-grpc-web plugin (https://github.com/grpc/grpc-web/tree/master/net/grpc/gateway/examples/helloworld#generate-protobuf-messages-and-client-service-stub)
# Mac Binary https://github.com/grpc/grpc-web/releases/download/1.2.0/protoc-gen-grpc-web-1.2.0-darwin-x86_64
# Linux Binary https://github.com/grpc/grpc-web/releases/download/1.2.0/protoc-gen-grpc-web-1.2.0-linux-x86_64

.PHONY: build-js
build-js: clean
	mkdir -p $(BUILD_JS_DIR)
	echo "$(GIT_TAG)"
	sed -i -e 's/0.0.1/$(GIT_TAG)/g' package.json
	protoc --proto_path=$(PROTO_PATH) -I=. $(PROTO_PATH)/*.proto --js_out=import_style=commonjs:$(BUILD_JS_DIR) \
		--grpc-web_out=import_style=commonjs+dts,mode=grpcwebtext:$(BUILD_JS_DIR) && ls -la $(BUILD_JS_DIR)
    
