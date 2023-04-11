#!/bin/bash
geth init --datadir . genesis.json
geth --datadir . --http --http.addr 0.0.0.0 --http.port 8565 --authrpc.port 9565 --http.corsdomain "*" --ws --ws.port 8566 --ws.origins "*" --dev --password password.txt --networkid 54321 --http.corsdomain '*' --ipcdisable