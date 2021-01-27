IMAGE := esp-adf-builder
VERSION := v2

env: image
	@echo "export ESP32_IMAGE=$(IMAGE):$(VERSION) ESP_XXX=hi"

image: $(IMAGE).stamp

$(IMAGE).stamp: Dockerfile
	docker build --tag $(IMAGE):$(VERSION) \
	    --tag $(IMAGE):$(VERSION) \
	    --tag $(IMAGE):latest \
	    .
	@touch $@
