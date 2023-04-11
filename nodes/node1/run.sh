#!/bin/bash
geth init --datadir . genesis.json
geth --datadir . --http --http.addr 0.0.0.0 --http.port 8545 --authrpc.port 9545 --http.corsdomain "*" --ws --ws.port 8546 --ws.origins "*" --dev --password password.txt --networkid 12345 --http.corsdomain '*' --ipcdisable