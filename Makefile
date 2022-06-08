build:
	GOOS=linux GOARCH=amd64 go build -o runpubip .

docker-build:
	docker build -t royge/runpubip .

docker-push:
	docker tag royge/runpubip gcr.io/${PROJECT_ID}/runpubip:latest
	docker push gcr.io/${PROJECT_ID}/runpubip:latest

deploy-env:
ifndef PROJECT_ID
	$(error PROJECT_ID is not defined)
endif
ifndef ENV
	$(error ENV is not defined)
endif

deploy: deploy-env
	gcloud config set project ${PROJECT_ID}
	gcloud run deploy \
	pubip \
	--image gcr.io/${PROJECT_ID}/runpubip:latest \
	--platform managed \
	--port 8080 \
	--memory 128Mi \
	--region asia-southeast1 \
	--allow-unauthenticated \
	--vpc-connector ${ENV}-cloud-run-connector \
	--vpc-egress all-traffic
