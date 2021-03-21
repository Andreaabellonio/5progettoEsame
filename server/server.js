//#region ISTANZE MODULI E INIZIALIZZAZIONE
//? CARICAMENTO DEI MODULI
const express = require("express");
const mongo = require("mongodb");
const mongoFunctions = require("./mongo.js");

//? ISTANZA MONGO CLIENT
const url = "mongodb://localhost:27017/";
const nomeDb = "thispensa";

//? CREAZIONE DEL SERVER
const app = express();
app.listen(13377, function () {
    mongoFunctions.settings(url, mongo.MongoClient);
    console.log("SERVER AVVIATO SULLA PORTA 13377");
});

//? GESTIONE RISORSE STATICHE
app.use("/", express.static("./static"));

//? GESTIONE CHIAMATE POST
app.use("/", express.json());
app.use("/", express.urlencoded({ "extended": true }));
//#endregion

//#region GESTIONE RICHIESTE

/*
app.post("/ricercaProdottoBarcode", function (req, res, next) {
    console.log(req.body);
    request('https://it.openfoodfacts.org/api/v0/product/' + req.body.codice.toString() + '.json', async function (error, response, body) {
        if (!error && response.statusCode == 200) {
            body = JSON.parse(body);
            //? Controllo se il risultato è valido oppure no
            if (body.status != 0) {
                console.log("prodotto letto correttamente");
                risposta.errore = false;
                risposta.nome = body.product.product_name; //nome del prodotto
                risposta.qta = body.product.quantity; //quantità
                risposta.tracce = body.product.traces.split(":")[1]; //tracce di alimenti
                risposta.urlImage = body.product.image_front_url; //immagine del prodotto
            }
            else {
                risposta.errore = true;
                risposta.messaggioErrore = "Prodotto non trovato o codice invalido. Riprovare";
            }
        }
        else {
            risposta.errore = true;
            risposta.messaggioErrore = "Errore nella richiesta del server. Riprovare";
        }
        res.send(JSON.stringify(risposta));
    });
});
*/

//? DATI INPUT
//barcode
app.post("/ricercaProdotto", function (req, res) {
    console.log("Barcode da ricercare: " + req.body.barcode);
    mongoFunctions.find(res, nomeDb, "prodotti", { barcode: req.body.barcode }, {}, function (data) {
        if (data.length > 0) {
            res.send(JSON.stringify({ trovato: true, prodotto: data }));
        }
        else
            res.send(JSON.stringify({ trovato: false }));
    });
});

//?DATI INPUT
//barcode
//idDispensa
//idUtente
//qta
//dataScadenza
app.post("/inserisciProdottoDispensa", function (req, res) {
    console.log("INSERIMENTO PRODOTTO IN DISPENSA");
    /*
    //? Con upsert se esiste fa l'update se non esiste lo inserisce
    mongoFunctions.findAndUpdate(res, nomeDb, "prodotti", { barcode: req.body.prodotto.barcode }, { $set: req.body.prodotto }, { upsert: true }, function (data) {
        mongoFunctions.update(res, nomeDb, "dispense", { _id: mongo.ObjectID(req.body.idDispensa) }, { $push: { "elementi": { idProdotto: data.value._id, dataInserimento: new Date(Date.now()), dataScadenza: new Date(req.body.dataScadenza), idUtente: mongo.ObjectID(req.body.idUtente), qta: req.body.qta } } }, {}, function (data) {
            res.send(JSON.stringify({ errore: false }));
        });
    });*/
    //? Con upsert se esiste fa l'update se non esiste lo inserisce
    mongoFunctions.update(res, nomeDb, "dispense", { _id: mongo.ObjectID(req.body.idDispensa) }, { $push: { "elementi": { idProdotto: req.body.barcode, dataInserimento: new Date(Date.now()), dataScadenza: new Date(req.body.dataScadenza), idUtente: mongo.ObjectID(req.body.idUtente), qta: req.body.qta } } }, {}, function (data) {
        res.send(JSON.stringify({ errore: false }));
    });
});
/*

app.post("/inserisciProdotto", function (req, res) {
    //? cerco se il prodotto è già presente nel db
    mongoFunctions.find(res, nomeDb, "prodotti", { barcode: req.body.prodotto.barcode }, {}, function (data) {
        console.log("RICERCA PRODOTTO" + data);
        if (data.length == 0) {
            console.log("NON ESISTE");
            //? se non è presente lo aggiungo
            mongoFunctions.insert(res, nomeDb, "prodotti", req.body.prodotto, function (data1) {
                console.log("INSERT PRODOTTO" + data1);
                //? da data prendo id?
                //? l'update la faccio in base all'id della dispensa dell'utente
                mongoFunctions.update(res, nomeDb, "dispensa", { _id: req.body.idDispensa }, { $push: { "elementi": { idProdotto: data1._id, dataInserimento: new Date(), idUtente: req.body.idUtente, qta: req.body.qta } } }, function (data2) {
                    console.log("UPDATE DISPENSA" + data2);
                });
            });
        }
        else {
            console.log("ESISTE");
            //? se è presente faccio l'update dei dati relativi al prodotto
            mongoFunctions.update(res, nomeDb, "prodotti", { barcode: req.body.barcode }, {}, function (data1) {
                console.log("UPDATE PRODOTTO" + data1);
                //? aggiorno la dispensa dell'utente
                mongoFunctions.update(res, nomeDb, "dispensa", { _id: req.body.idDispensa }, { $push: { "elementi": { idProdotto: data1._id, dataInserimento: new Date(), idUtente: req.body.idUtente, qta: req.body.qta } } }, function (data2) {
                    console.log("UPDATE DISPENSA" + data2);
                });
            });
        }
    });
});*/

//?DATI INPUT
//idDispensa
app.post("/leggiDispensa", function (req, res) {
    mongoFunctions.find(res, nomeDb, "dispense", { _id: mongo.ObjectID(req.body.idDispensa) }, {}, function (data) {
        res.send(JSON.stringify({ errore: false, prodotto: data }));
    });
});

//?DATI INPUT
//oggetto prodotto
app.post("/aggiornaProdotto", function (req, res) {
    mongoFunctions.update(res, nomeDb, "prodotti", { barcode: req.body.barcode }, { $set: req.body.prodotto }, { upsert: true }, function (data) {
        res.send(JSON.stringify({ errore: false }));
    });
});

//? DATI INPUT
//barcode
app.post("/eliminaProdotto", function (res, req) {
    mongoFunctions.deleteMany(res, nomeDb, "prodotti", { barcode: req.body.barcode }, function (data) {
        res.send(JSON.stringify({ errore: false }));
    });
});

//#endregion

//#region FUNZIONI AGGIUNTIVE

//#endregion
