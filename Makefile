S3_BUCKET = thisisatestbucketegzaggny5873
S3_KEY = tf.tfstate
S3_REGION = us-east-1

docker_build:
	docker build -t server .

tf_init:
	cd tf && terraform init -backend-config="bucket=$(S3_BUCKET)" -backend-config="key=$(S3_KEY)" -backend-config="region=$(S3_REGION)"

tf_plan:
	cd tf && terraform plan

tf_apply:
	cd tf && terraform apply
