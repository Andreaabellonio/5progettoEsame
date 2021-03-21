"use strict";

//#region ISTANZE MODULI E INIZIALIZZAZIONE
//? CARICAMENTO DEI MODULI
var express = require("express");

var mongo = require("mongodb");

var mongoFunctions = require("./mongo.js"); //? ISTANZA MONGO CLIENT


var url = "mongodb://localhost:27017/";
var nomeDb = "thispensa"; //? CREAZIONE DEL SERVER

var app = express();
app.listen(13377, function () {
  mongoFunctions.settings(url, mongo.MongoClient);
  console.log("SERVER AVVIATO SULLA PORTA 13377");
}); //? GESTIONE RISORSE STATICHE

app.use("/", express["static"]("./static")); //? GESTIONE CHIAMATE POST

app.use("/", express.json());
app.use("/", express.urlencoded({
  "extended": true
})); //#endregion
//#region GESTIONE RICHIESTE
//? DATI INPUT
//barcode

app.post("/ricercaProdotto", function (req, res) {
  console.log("Barcode da ricercare: " + req.body.barcode);
  mongoFunctions.find(res, nomeDb, "prodotti", {
    barcode: req.body.barcode
  }, {}, function (data) {
    if (data.length > 0) {
      res.send(JSON.stringify({
        trovato: true,
        prodotto: data
      }));
    } else res.send(JSON.stringify({
      trovato: false
    }));
  });
}); //?DATI INPUT
//prodotto(che contiene tutti i dati come da database)
//idDispensa
//idUtente
//qta
//dataScadenza

app.post("/inserisciProdottoDispensa", function (req, res) {
  /*
  //? Con upsert se esiste fa l'update se non esiste lo inserisce
  mongoFunctions.findAndUpdate(res, nomeDb, "prodotti", { barcode: req.body.prodotto.barcode }, { $set: req.body.prodotto }, { upsert: true }, function (data) {
      mongoFunctions.update(res, nomeDb, "dispense", { _id: mongo.ObjectID(req.body.idDispensa) }, { $push: { "elementi": { idProdotto: data.value._id, dataInserimento: new Date(Date.now()), dataScadenza: new Date(req.body.dataScadenza), idUtente: mongo.ObjectID(req.body.idUtente), qta: req.body.qta } } }, {}, function (data) {
          res.send(JSON.stringify({ errore: false }));
      });
  });*/
  //? Con upsert se esiste fa l'update se non esiste lo inserisce
  mongoFunctions.update(res, nomeDb, "dispense", {
    _id: mongo.ObjectID(req.body.idDispensa)
  }, {
    $push: {
      "elementi": {
        idProdotto: req.body.barcode,
        dataInserimento: new Date(Date.now()),
        dataScadenza: new Date(req.body.dataScadenza),
        idUtente: mongo.ObjectID(req.body.idUtente),
        qta: req.body.qta
      }
    }
  }, {}, function (data) {
    res.send(JSON.stringify({
      errore: false
    }));
  });
}); //?DATI INPUT
//idDispensa

app.post("/leggiDispensa", function (req, res) {
  mongoFunctions.find(res, nomeDb, "dispense", {
    _id: mongo.ObjectID(req.body.idDispensa)
  }, {}, function (data) {
    res.send(JSON.stringify({
      errore: false,
      prodotto: data
    }));
  });
}); //?DATI INPUT
//oggetto prodotto

app.post("/aggiornaProdotto", function (req, res) {
  mongoFunctions.update(res, nomeDb, "prodotti", {
    barcode: req.body.barcode
  }, {
    $set: req.body.prodotto
  }, {
    upsert: true
  }, function (data) {
    res.send(JSON.stringify({
      errore: false
    }));
  });
}); //? DATI INPUT
//barcode

app.post("/eliminaProdotto", function (res, req) {
  mongoFunctions.deleteMany(res, nomeDb, "prodotti", {
    barcode: req.body.barcode
  }, function (data) {
    res.send(JSON.stringify({
      errore: false
    }));
  });
}); //#endregion
//#region FUNZIONI AGGIUNTIVE
//#endregion