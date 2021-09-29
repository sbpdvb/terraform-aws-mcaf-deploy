package main

import (
	"flag"
	"log"
	"os"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/codebuild"
)

func main() {
	// Configure and parse two required flags.
	projectName := flag.String("project-name", "", "Name of the CodeBuild build project to trigger (required)")
	sourceVersion := flag.String("source-version", "", "Version of the build input to checkout and use (required)")
	flag.Parse()

	// Make sure both flags are set.
	if projectName == nil || *projectName == "" || sourceVersion == nil || *sourceVersion == "" {
		flag.Usage()
		os.Exit(2)
	}

	// Get the region from the environment.
	region := os.Getenv("AWS_REGION")
	if region == "" {
		region = os.Getenv("AWS_DEFAULT_REGION")
	}

	// Creating a new AWS session.
	sess, err := session.NewSession(&aws.Config{
		Region: aws.String(region),
	})
	if err != nil {
		log.Fatalf("Failed to create a new AWS session: %v", err)
	}

	// Create the CodeBuild client.
	svc := codebuild.New(sess)

	// Define the required input parameters.
	input := &codebuild.StartBuildInput{
		ProjectName:   projectName,
		SourceVersion: sourceVersion,
	}

	// Trigger all our pipelines by starting a new build.
	_, err = svc.StartBuild(input)
	if err != nil {
		log.Fatalf("Failed to start new build: %v", err)
	}

	log.Printf("Build %q triggered successfully", *projectName)
}
