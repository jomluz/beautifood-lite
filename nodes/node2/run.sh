#!/bin/bash
geth init --datadir . genesis.json
geth --datadir . --http --http.addr 0.0.0.0 --http.port 8565 --authrpc.port 9565 --http.corsdomain "*" --dev --password password.txt --networkid 54321 --http.corsdomain '*' --ipcdisable