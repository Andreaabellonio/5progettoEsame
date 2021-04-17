//#region ISTANZE MODULI E INIZIALIZZAZIONE
//? CARICAMENTO DEI MODULI
const express = require("express");
const mongo = require("mongodb");
const session = require("express-session");
const mongoFunctions = require("./mongo.js");
const admin = require("firebase-admin");

//? ISTANZA MONGO CLIENT
const url = "mongodb://localhost:27017/";
const nomeDb = "thispensa";

//? CREAZIONE DEL SERVER
const app = express();
app.listen(13377, function () {
    mongoFunctions.settings(url, mongo.MongoClient);
    console.log("SERVER AVVIATO SULLA PORTA 13377");
});

//? INIZIALIZZAZIONE FIREBASE ADMIN
var firebaseAdmin = admin.initializeApp();

//? INIZIALIZZAZIONE SESSION
app.use(session({
    secret: "passwordsegretissima", //chiave per crittografare il cookie
    name: "sessionId",
    // proprietà legate allo Store
    resave: false, //forza il salvataggio della session anche se non viene modificata da ulteriori richieste
    saveUninitialized: false, //forza il salvataggio anche di session nuove o non inizializzate
    cookie: {
        secure: false,// true per accessi https
        maxAge: 24 * 60 * 60 * 1000, // durata in msec
        expires: false
    }
}));
/*
//? CONTROLLO SESSION SU TUTTE LE RICHIESTE
app.use("/", function (req, res, next) {
    if (req.session.auth)
        next(); //se autenticato passa alle funzioni successive
    else
        res.send(JSON.stringify({ errore: true, messaggio: "Accesso vietato, non sei autenticato" }));
});
*/
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
    let dato = {
        idProdotto: req.body.barcode,
        dataInserimento: new Date(Date.now()),
        dataScadenza: new Date(req.body.dataScadenza),
        idUtente: mongo.ObjectID(req.body.idUtente),
        qta: req.body.qta
    };
    console.log("INSERIMENTO PRODOTTO IN DISPENSA");
    //? Con upsert se esiste fa l'update se non esiste lo inserisce
    mongoFunctions.update(res, nomeDb, "dispense", { _id: mongo.ObjectID(req.body.idDispensa) }, { $push: { "elementi": dato } }, {}, function (data) {
        res.send(JSON.stringify({ errore: false }));
    });
});

//?DATI INPUT
//barcode
//idDispensa
//idUtente
//qta
//dataScadenza
app.post("/aggiornaProdottoDispensa", function (req, res) {
    let dato = {
        idProdotto: req.body.barcode,
        dataScadenza: new Date(req.body.dataScadenza),
        idUtente: mongo.ObjectID(req.body.idUtente),
        qta: req.body.qta
    };
    mongoFunctions.update(res, nomeDb, "dispense", { _id: mongo.ObjectID(req.body.idDispensa) }, { $set: dato }, {}, function (data) {
        res.send(JSON.stringify({ errore: false }));
    });
});

//?DATI INPUT
//idDispensa
app.post("/leggiDispensa", function (req, res) {
    console.log("LETTURA DISPENSA");
    mongoFunctions.find(res, nomeDb, "dispense", { _id: mongo.ObjectID(req.body.idDispensa) }, { elementi: 1 }, function (data) {
        res.send(JSON.stringify({ errore: false, prodotti: data[0]["elementi"] }));
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

//? DATI INPUT
//email
//username
app.post("/login", function (res, req) {
    firebaseAdmin.auth().getUser(req.body.uid).then((userRecord)=>{
        console.log(userRecord);
    })
    .catch((console.error();))
    /*
    mongoFunctions.find(res, nomeDb, "utenti", { email: req.body.email, password: req.body.password }, {}, function (data) {
        if (data.lenght == 1) {
            req.session.auth = true;
            res.send(JSON.stringify({ errore: false }));
        }
        else {
            res.send(JSON.stringify({ errore: true }));
        }
    });*/
});

app.post("/logout", function (req, res) {
    req.session.destroy();
});

//? DATI INPUT
// nome
// cognome
// email
// password
//? DATI OUTPUT
// idListaDellaSpesa
// idDispensa
app.post("/registrazione", function (req, res) {
    let dato = {
        dataCreazione: new Date(Date.now()),
        nome: req.body.nome,
        cognome: req.body.cognome,
        email: req.body.email,
        password: req.body.password
    };
    mongoFunctions.insertOne(res, nomeDb, "liste_della_spesa", {}, function (listaDellaSpesa) {
        mongoFunctions.insertOne(res, nomeDb, "dispense", {}, function (dispense) {
            dato.listeDellaSpesa.push(listaDellaSpesa._id);
            dato.dispense.push(dispense._id);
            mongoFunctions.insertOne(res, nomeDb, "utenti", { dato }, function (data) {
                res.send(JSON.stringify({ errore: false, listaDellaSpesa: dato.listeDellaSpesa, dispensa: dato.dispense }));
            });
        });
    });
});
//#endregion

//#region FUNZIONI AGGIUNTIVE

//#endregion
