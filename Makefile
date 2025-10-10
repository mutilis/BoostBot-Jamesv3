# --------------------------------------------------
#   Makefile for Discord Bot (Prod + Debug)
# --------------------------------------------------

# Image names
PROD_IMAGE=my-bot
DEBUG_IMAGE=my-bot-debug

# Config path
CONFIG_FILE=$(PWD)/.config.json

# Default target
all: prod

# --------------------------------------------------
#   Build images
# --------------------------------------------------

build-prod:
	docker build -f Dockerfile -t $(PROD_IMAGE) .

build-debug:
	docker build -f Dockerfile.debug -t $(DEBUG_IMAGE) .

# --------------------------------------------------
#   Run containers
# --------------------------------------------------

prod: build-prod
	@echo "🚀 Starting prod container..."
	docker run -d --name $(PROD_IMAGE) \
		--read-only \
		--pids-limit=200 \
		--memory=128m \
		--cap-drop=ALL \
		--tmpfs /tmp:rw,nosuid,nodev,noexec,size=16m \
		--restart unless-stopped \
		-v $(PWD)/.config.json:/app/.config.json:ro \
		-v $(PWD)/banners:/app/banners:rw \
		-v $(PWD)/ttbb-data:/app/ttbb-data:rw \
		$(PROD_IMAGE)



debug: build-debug
	@echo "🐞 Starting debug container (Delve on :4000)..."
	docker run -d --name $(DEBUG_IMAGE) -p 4000:4000 \
		--read-only \
		--pids-limit=200 \
		--memory=128m \
		--cap-drop=ALL \
		--tmpfs /tmp:rw,nosuid,nodev,noexec,size=16m \
		--restart unless-stopped \
		-v $(PWD)/.config.json:/app/.config.json:ro \
		-v $(PWD)/banners:/app/banners:rw \
		-v $(PWD)/ttbb-data:/app/ttbb-data:rw \
		$(DEBUG_IMAGE)


# --------------------------------------------------
#   Stop & cleanup
# --------------------------------------------------

stop:
	@echo "🛑 Stopping running containers..."
	-docker stop $(PROD_IMAGE) 2>/dev/null || true
	-docker rm $(PROD_IMAGE) 2>/dev/null || true
	-docker stop $(DEBUG_IMAGE) 2>/dev/null || true
	-docker rm $(DEBUG_IMAGE) 2>/dev/null || true

clean: stop
	@echo "🧹 Removing unused Docker resources..."
	docker system prune -af


# --------------------------------------------------
#   Rebuild (clean + debug)
# --------------------------------------------------

rebuild: clean
	@echo "🔁 Cleaning and rebuilding debug container..."
	make debug


# --------------------------------------------------
#   Logs
# --------------------------------------------------

logs-prod:
	docker logs -f $(PROD_IMAGE)

logs-debug:
	docker logs -f $(DEBUG_IMAGE)