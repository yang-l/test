package main

import (
	"encoding/json"
	"log"
	"net/http"
)

type count struct {
	Count int `json:"count"`
}

type message struct {
	Msg string `json:"msg"`
}

var noCount int

func countHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	switch r.Method {
	case http.MethodHead:
		fallthrough
	case http.MethodGet:
		noCount++
		j, _ := json.Marshal(&count{
			Count: noCount,
		})
		w.Write(j)
	default:
		w.WriteHeader(http.StatusMethodNotAllowed)

		j, _ := json.Marshal(&message{
			Msg: "405 - Method not allowed",
		})
		w.Write(j)
	}
}

func router() http.Handler {
	mux := http.NewServeMux()
	mux.HandleFunc("/count", countHandler)
	return mux
}

func main() {
	log.Println("Service Started")
	log.Fatal(http.ListenAndServe(":8080", router()))
}
