//#region ISTANZE MODULI E INIZIALIZZAZIONE
//? VARIABILI GLOBALI
const lingua = "it";

//? CARICAMENTO DEI MODULI
const express = require("express");
const request = require("request");
const mongo = require("mongodb");
const bodyParser = require("body-parser");
const fetch = require("node-fetch");
var AWS = require("aws-sdk");

AWSCredentialsProviderChain DefaultAWSCredentialsProviderChain = new AWSCredentialsProviderChain(
                new SystemPropertiesCredentialsProvider(),
                new EnvironmentVariableCredentialsProvider(),
                new ProfileCredentialsProvider()
        );

        // Create an Amazon Translate client
        AmazonTranslate translate = AmazonTranslateClient.builder()
                .withCredentials(DefaultAWSCredentialsProviderChain)
                .withRegion(region)
                .build();
                
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
app.get("/prova", function (req, res, next) {
    request('https://world.openfoodfacts.org/api/v0/product/8000500310427.json', async function (error, response, body) {
        if (!error && response.statusCode == 200) {
            body = JSON.parse(body);
            let prodotto = new Object();
            prodotto.nome = await asyncTranslate(lingua, body.product.generic_name);
            prodotto.qta = body.product.quantity;
            prodotto.tracce = await asyncTranslate(lingua, body.product.traces.split(":")[1]); //! gestire se non c'è ne sono
            await res.send(JSON.stringify(prodotto));
        }
    });
});
app.get("/test", function (req, res, next) {
    translate.translateText(params, function (err, data) {
        if (err) console.log(err, err.stack);
        else console.log(data['TranslatedText']);
    });
});
//#endregion

//#region FUNZIONI AGGIUNTIVE
//? FUNZIONE PER LA TRADUZIONE DEL TESTO
async function traduci(target, text) {
    let testo = await fetch("https://eu-central-1.console.aws.amazon.com/translate/api/translate", {
        contentString: JSON.stringify({
            "TargetLanguageCode": target,
            "Text": text,
            "SourceLanguageCode": "auto"
        }),
        headers: JSON.stringify({
            "Content-Type": "application/x-amz-json-1.1",
            "X-Amz-Target": "AWSShineFrontendService_20170701.TranslateText",
            "X-Amz-User-Agent": "aws-sdk-js/2.306.0 promise"
        }),
        method: "POST",
        operation: "translateText",
        params: {},
        path: "/",
        region: "eu-central-1"
    });
    let tradotto = await testo;
    return tradotto.TranslatedText;
}
//#endregion