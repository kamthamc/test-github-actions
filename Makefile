GIT_TAG = $(shell git describe --tags)
BUILD_JS_DIR = dist/build-js
PROTO_PATH = protobuf


.PHONY: setup-protobuf
setup-protobuf:
	wget https://github.com/protocolbuffers/protobuf/releases/download/v3.12.3/protoc-3.12.3-linux-x86_64.zip -O /tmp/protoc.zip
	unzip /tmp/protoc.zip -d /tmp/protoc
	mv /tmp/protoc/bin/protoc /usr/local/bin/protoc
	chmod +x /usr/local/bin/protoc

	wget https://github.com/grpc/grpc-web/releases/download/1.2.0/protoc-gen-grpc-web-1.2.0-linux-x86_64 -O /usr/local/bin/protoc-gen-grpc-web
	chmod +x /usr/local/bin/protoc-gen-grpc-web


.PHONY: clean
clean:
	rm -rf $(BUILD_JS_DIR)

# Requires protoc and protoc-gen-grpc-web plugin (https://github.com/grpc/grpc-web/tree/master/net/grpc/gateway/examples/helloworld#generate-protobuf-messages-and-client-service-stub)
# Mac Binary https://github.com/grpc/grpc-web/releases/download/1.2.0/protoc-gen-grpc-web-1.2.0-darwin-x86_64
# Linux Binary https://github.com/grpc/grpc-web/releases/download/1.2.0/protoc-gen-grpc-web-1.2.0-linux-x86_64

.PHONY: build-js
build-js: clean
	mkdir -p $(BUILD_JS_DIR)
	cp package.json $(BUILD_JS_DIR)/package.json
	sed 's/0.0.1/$(VERSION)/g' $(BUILD_JS_DIR)/package.json  $(BUILD_JS_DIR)/package.json
	protoc --proto_path=$(PROTO_PATH) -I=. $(PROTO_PATH)/*.proto --js_out=import_style=commonjs:$(BUILD_JS_DIR) \
		--grpc-web_out=import_style=commonjs+dts,mode=grpcwebtext:$(BUILD_JS_DIR) && ls -la $(BUILD_JS_DIR)
    
