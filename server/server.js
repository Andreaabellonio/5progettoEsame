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
//#endregion

//#region FUNZIONI AGGIUNTIVE
//#endregion