// +build generate

package main

import (
	"net/http"

	"github.com/shurcooL/vfsgen"
)

func main() {
	fs := http.Dir("web/dist")
	err := vfsgen.Generate(fs, vfsgen.Options{
		Filename:     "assets.go",
		VariableName: "assets",
	})
	if err != nil {
		panic(err)
	}
}
