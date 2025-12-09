.PHONY: help setup install test lint format clean docker-build docker-push deploy

# Variables
PROJECT_ID ?= multiverse-analyzer
REGION ?= us-central1
CLUSTER_NAME ?= multiverse-cluster
IMAGE_NAME = gcr.io/$(PROJECT_ID)/multiverse-analyzer
VERSION ?= latest

help:
	@echo "Available commands:"
	@echo "  setup         - Initial project setup"
	@echo "  install       - Install dependencies"
	@echo "  test          - Run tests"
	@echo "  lint          - Run linters"
	@echo "  format        - Format code"
	@echo "  docker-build  - Build Docker image"
	@echo "  docker-push   - Push Docker image"
	@echo "  deploy        - Deploy to GKE"

setup:
	@echo "Setting up project..."
	pip install -r requirements.txt
	pre-commit install

install:
	pip install -e .

test:
	pytest tests/ -v --cov=src --cov-report=html

lint:
	flake8 src tests
	mypy src

format:
	black src tests
	isort src tests

clean:
	find . -type d -name "__pycache__" -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
	find . -type f -name "*.pyo" -delete

docker-build:
	docker build -t $(IMAGE_NAME):$(VERSION) .
	docker tag $(IMAGE_NAME):$(VERSION) $(IMAGE_NAME):latest

docker-push:
	docker push $(IMAGE_NAME):$(VERSION)
	docker push $(IMAGE_NAME):latest

deploy:
	@echo "Deploying to GKE cluster: $(CLUSTER_NAME)"
	kubectl apply -f kubernetes/
	kubectl rollout status deployment/multiverse-analyzer
