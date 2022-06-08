package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"

	"github.com/gorilla/mux"
)

func main() {
	r := mux.NewRouter()
	httpAddr := ":8080"

	r.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		ip := getPublicIP()
		fmt.Fprint(w, ip)
	})

	// Health and readiness check routes.
	r.HandleFunc("/healthy", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json; charset=utf-8")
	})
	r.HandleFunc("/ready", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json; charset=utf-8")
	})

	errs := make(chan error)
	go func() {
		c := make(chan os.Signal, 1)
		signal.Notify(c, syscall.SIGINT, syscall.SIGTERM)
		errs <- fmt.Errorf("%s", <-c)
	}()

	go func() {
		log.Println("Address", httpAddr)

		srv := &http.Server{
			Addr:    httpAddr,
			Handler: r,
		}

		errs <- srv.ListenAndServe()

	}()

	log.Fatal("exit", <-errs)
}

func getPublicIP() string {
	url := "https://api.ipify.org"
	log.Println("Requesting to", url)
	res, err := http.Get(url)
	if err != nil {
		return err.Error()
	}
	defer res.Body.Close()

	b, err := ioutil.ReadAll(res.Body)
	if err != nil {
		return err.Error()
	}

	if err != nil {
		return err.Error()
	}
	return fmt.Sprintf("%s", b)
}
