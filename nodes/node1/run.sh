#!/bin/bash
geth init --datadir . genesis.json
geth --datadir . --http --http.addr 0.0.0.0 --http.port 8545 --authrpc.port 9545 --http.corsdomain "*" --dev --password password.txt --networkid 12345 --http.corsdomain '*' --ipcdisable