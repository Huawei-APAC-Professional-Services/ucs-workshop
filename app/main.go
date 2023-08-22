package main

import (
	"context"
	"embed"
	"html/template"
	"net/http"
	"os"

	"github.com/gin-gonic/gin"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"
)

var region string
var podName string

//go:embed templates/*
var templates embed.FS

func init() {
	config, err := rest.InClusterConfig()
	if err != nil {
		panic(err.Error())
	}
	clientset, err := kubernetes.NewForConfig(config)
	if err != nil {
		panic(err.Error())
	}
	nodes, err := clientset.CoreV1().Nodes().List(context.TODO(), metav1.ListOptions{})
	if err != nil {
		panic(err.Error())
	}
	if len(nodes.Items) == 0 {
		panic("No Node Has been found")
	}
	region = nodes.Items[0].Labels["topology.kubernetes.io/region"]
	podName = os.Getenv("HOSTNAME")
}

func main() {
	r := gin.Default()
	templ := template.Must(template.New("").ParseFS(templates, "templates/*.tmpl"))
	r.SetHTMLTemplate(templ)
	r.GET("/", func(ctx *gin.Context) {
		ctx.HTML(http.StatusOK, "index.tmpl", gin.H{"Region": region, "Pod": podName})
	})
	r.Run("0.0.0.0:80")
}
