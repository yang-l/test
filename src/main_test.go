package main

import (
	"io/ioutil"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestCountHandler(t *testing.T) {
	expected := `{"count":1}`

	rec := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/count", nil)

	countHandler(rec, req)

	rsp := rec.Result()

	if rsp.StatusCode != http.StatusOK {
		t.Errorf("Got HTTP response status code %d, expected %d", rsp.StatusCode, 200)
	}

	defer rsp.Body.Close()
	body, e := ioutil.ReadAll(rsp.Body)
	if e != nil {
		t.Errorf("Failed to get response body: %v", e)
	}

	if string(body) != expected {
		t.Errorf("Got HTTP response body %v, expected %v", string(body), string(expected))
	}
}
