//#region ISTANZE MODULI E INIZIALIZZAZIONE

//? CARICAMENTO DEI MODULI
const express = require("express");
const request = require("request");
const mongo = require("mongodb");
const bodyParser = require("body-parser");

//? CREAZIONE DEL SERVER
const app = express();
app.listen(13377, function () {
    console.log("SERVER AVVIATO SULLA PORTA 13377");
});

//? ISTANZA MONGO CLIENT
const mongoClient = mongo.MongoClient;

//? GESTIONE RISORSE STATICHE
app.use("/", express.static("./static"));

//? GESTIONE CHIAMATE POST
app.use("/", bodyParser.json());
app.use("/", bodyParser.urlencoded({ "extended": true }));
//#endregion

//#region GESTIONE RICHIESTE
app.post("/prova", function (req, res, next) {
    console.log(req.body);
    request('https://world.openfoodfacts.org/api/v0/product/' + req.body.codice.toString() + '.json', async function (error, response, body) {
        if (!error && response.statusCode == 200) {
            body = JSON.parse(body);
            let prodotto = new Object();
            prodotto.nome = body.product.product_name; //nome del prodotto
            prodotto.qta = body.product.quantity; //quantità
            prodotto.tracce = body.product.traces.split(":")[1]; //! gestire se non c'è ne sono
            prodotto.urlImage = body.product.image_front_url; //immagine del prodotto
            res.send(JSON.stringify(prodotto));
        }
    });
});
//#endregion

//#region FUNZIONI AGGIUNTIVE
//#endregion