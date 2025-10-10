package main

import (
	"github.com/mkmccarty/TokenTimeBoostBot/src/bottools"
)

func main() {
	bottools.GenerateSnapshots("src/ei/contract_snapshots.go", "ei")
}
