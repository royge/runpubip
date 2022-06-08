build:
	GOOS=linux GOARCH=amd64 go build -o runpubip .

docker-build:
	docker build -t royge/runpubip .

docker-push: project-env
	docker tag royge/runpubip gcr.io/${PROJECT_ID}/runpubip:latest
	docker push gcr.io/${PROJECT_ID}/runpubip:latest

deploy-env: project-env
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

project-env:
ifndef PROJECT_ID
	$(error PROJECT_ID is not defined)
endif

destroy: project-env
	gcloud config set project ${PROJECT_ID}
	gcloud run services delete pubip \
		--platform managed \
		--region asia-southeast1 \
		--quiet
