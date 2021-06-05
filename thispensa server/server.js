//#region ISTANZE MODULI E INIZIALIZZAZIONE
//? CARICAMENTO DEI MODULI
const express = require("express");
const mongo = require("mongodb");
const session = require("express-session");
const mongoFunctions = require("./mongo.js");
const admin = require("firebase-admin");
//const schedule = require("node-schedule");

const serviceAccount = require("./thispensa-f54e0-firebase-adminsdk-nglrb-963863e898.json");

//? ISTANZA MONGO CLIENT
const url = "mongodb+srv://server:ykBndA9L5mzMdsgy@cluster0.xsllc.mongodb.net/thispensa?retryWrites=true&w=majority";
const nomeDb = "thispensa";

//? CREAZIONE DEL SERVER
const app = express();
app.listen(process.env.PORT || 13377, function () {
    mongoFunctions.settings(url, mongo.MongoClient);
    //schedule.scheduleJob('0 0 * * *', () => { auto(); }); //? schedule di auto ogni notte a mezzanotte
    console.log("Express server listening on port %d in %s mode", this.address().port, app.settings.env);
});

//? INIZIALIZZAZIONE FIREBASE ADMIN
admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});

//? INIZIALIZZAZIONE SESSION
app.use(session({
    secret: "passwordsegretissima", //chiave per crittografare il cookie
    name: "sessionId",
    // proprietà legate allo Store
    resave: true, //forza il salvataggio della session anche se non viene modificata da ulteriori richieste
    saveUninitialized: true, //forza il salvataggio anche di session nuove o non inizializzate
    cookie: {
        secure: false, // true per accessi https
        maxAge: 24 * 60 * 60 * 1000, // durata in msec
        expires: false,
        sameSite: false
    }
}));

//? GESTIONE CHIAMATE POST
app.use(express.json());
app.use(express.urlencoded({ "extended": true }));

app.use("/", function (req, res, next) {
    //Faccio il log di tutte le chiamate che arrivano al server, salvando anche l'ora
    let data = new Date();
    console.log(data.toLocaleTimeString() + ": " + req.originalUrl);
    next();
});

//#region gestioneLogin&Registrazione
//!SONO PRIMA DEL CONTROLLO SULLA SESSION PERCHE' NON E' ANCORA AUTENTICATO

app.post("/controllaEmail", function (req, res) {
    mongoFunctions.find(res, nomeDb, "utenti", { email: req.body.email }, {}, function (data) {
        if (data.length > 0)
            res.send(JSON.stringify({ errore: true }));
        else
            res.send(JSON.stringify({ errore: false }));
    });
});

//? DATI INPUT
//email
//username
app.post("/login", function (req, res) {
    admin
        .auth()
        .verifyIdToken(req.body.tokenJWT)
        .then((decodedToken) => {
            admin.auth().getUser(req.body.uid).then((userRecord) => {
                mongoFunctions.find(res, nomeDb, "utenti", { email: userRecord.email }, {}, async function (data) {
                    if (data.length == 1) {
                        req.session.auth = true;
                        res.send(JSON.stringify({ errore: false }));
                    } else
                        res.send(JSON.stringify({ errore: true }));
                });
            })
                .catch((error) => {
                    if (error.errorInfo.code == "auth/user-not-found")
                        res.send(JSON.stringify({ errore: true, messaggio: "Utente non trovato" }));
                });
        })
        .catch((error) => {
            res.send(JSON.stringify({ errore: true }));
        });
});

//? DATI INPUT
// nome
// cognome
// email
//? DATI OUTPUT
// idListaDellaSpesa
// idDispensa
app.post("/registrazione", function (req, res) {
    admin.auth().getUser(req.body.uid).then((userRecord) => {
        let dato = {
            _id: req.body.uid,
            dataCreazione: new Date(Date.now()),
            nome: req.body.nome,
            cognome: req.body.cognome,
            email: userRecord.email,
        };
        mongoFunctions.insertOne(res, nomeDb, "liste_della_spesa", { nome: req.body.nomeLista, elementi: [], creatore: req.body.uid }, function (listaDellaSpesa) {
            dato.listeDellaSpesa = [listaDellaSpesa.insertedId];
            mongoFunctions.insertOne(res, nomeDb, "utenti", dato, function (data) {
                res.send(JSON.stringify({ errore: false }));
            });
        });
    })
        .catch((error) => {
            res.send(JSON.stringify({ errore: true }));
        });
});

//? chiamata sia per login sia per registrazione, non cambia
app.post("/collegamentoAccountGoogle", function (req, res) {
    admin
        .auth()
        .verifyIdToken(req.body.tokenJWT)
        .then((decodedToken) => {
            admin.auth().getUser(req.body.uid).then((userRecord) => {
                let dato = {
                    _id: req.body.uid,
                    dataCreazione: new Date(Date.now()),
                    nome: userRecord.displayName,
                    email: userRecord.email,
                };
                mongoFunctions.find(res, nomeDb, "utenti", { email: userRecord.email }, {}, function (utente) {
                    if (utente.length == 1) {
                        req.session.auth = true;
                        res.send(JSON.stringify({ errore: false, listaDellaSpesa: utente.listeDellaSpesa, dispensa: utente.dispense }));
                    } else {
                        mongoFunctions.insertOne(res, nomeDb, "liste_della_spesa", { elementi: [], creatore: req.body.uid }, function (listaDellaSpesa) {
                            dato.listeDellaSpesa = [listaDellaSpesa.insertedId];
                            mongoFunctions.insertOne(res, nomeDb, "utenti", dato, function (data) {
                                req.session.auth = true;
                                res.send(JSON.stringify({ errore: false }));
                            });
                        });
                    }
                });
            })
                .catch((error) => {
                    res.send(JSON.stringify({ errore: true }));
                });
        })
        .catch((error) => {
            res.send(JSON.stringify({ errore: true }));
        });
});
//#endregion

//? CONTROLLO SESSION SU TUTTE LE RICHIESTE
app.use("/", function (req, res, next) {
    if (req.session.auth)
        next(); //! se autenticato passa alle funzioni successive
    else
        admin
            .auth()
            .verifyIdToken(req.body.tokenJWT)
            .then((decodedToken) => {
                admin.auth().getUser(req.body.uid).then((userRecord) => {
                    if (userRecord != null)
                        next();
                })
                    .catch((error) => {
                        if (error.errorInfo.code == "auth/user-not-found")
                            res.send(JSON.stringify({ errore: true, messaggio: "Utente non trovato" }));
                    });
            })
            .catch((error) => {
                res.send(JSON.stringify({ errore: true }));
            });
});

//? GESTIONE RISORSE STATICHE
app.use("/", express.static("./static"));

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

//#region gestioneUtenti

//? Lettura dati relativi all'utente
app.post("/leggiUtente", function (req, res) {
    mongoFunctions.find(res, nomeDb, "utenti", { _id: req.body.uid }, { nome: 1, cognome: 1, email: 1 }, function (data) {
        res.send(JSON.stringify({ errore: false, data: data[0] }));
    });
});

//? Aggiornamento dati utente
app.post("/aggiornaUtente", function (req, res) {
    mongoFunctions.update(res, nomeDb, "utenti", { _id: req.body.uid }, { $set: { nome: req.body.nome, cognome: req.body.cognome } }, {}, function (data) {
        res.send(JSON.stringify({ errore: false }));
    });
});

//? AGGIORNAMENTO CODICE FCM
app.post("/aggiornaTokenFCM", function (req, res) {
    mongoFunctions.update(res, nomeDb, "utenti", { _id: req.body.uid }, { $set: { tokenFCM: req.body.token } }, { upsert: true }, function (data) {
        res.send(JSON.stringify({ errore: false }));
    });
});

//? elimino solamente le dispense e le liste create dell'utente
app.post("/eliminaAccount", function (req, res) {
    mongoFunctions.deleteMany(res, nomeDb, "dispense", { creatore: req.body.uid }, function (data) {
        mongoFunctions.deleteMany(res, nomeDb, "liste_della_spesa", { creatore: req.body.uid }, function (data) {
            mongoFunctions.deleteMany(res, nomeDb, "utenti", { _id: req.body.uid }, function (data) {
                res.send(JSON.stringify({ errore: false }));
            });
        });
    });
});

//? LOGOUT
app.post("/logout", function (req, res) {
    req.session.destroy();
    res.send(JSON.stringify({ errore: false }));
});
//#endregion

//#region gestioneProdotti

//? Ricerca prodotto dato il barcode
app.post("/ricercaProdotto", function (req, res) {
    mongoFunctions.find(res, nomeDb, "prodotti", { barcode: req.body.barcode }, {}, function (data) {
        if (data.length > 0) {
            res.send(JSON.stringify({ trovato: true, prodotto: data }));
        } else
            res.send(JSON.stringify({ trovato: false }));
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
app.post("/eliminaProdotto", function (req, res) {
    mongoFunctions.deleteMany(res, nomeDb, "prodotti", { barcode: req.body.barcode }, function (data) {
        res.send(JSON.stringify({ errore: false }));
    });
});
//#endregion

//#region gestioneDispense

//? creazione della dispensa
app.post("/creaDispensa", function (req, res) {
    mongoFunctions.find(res, nomeDb, "dispense", { nome: req.body.nomeDispensa, creatore: req.body.uid }, {}, function (data) {
        if (data.length == 0)
            mongoFunctions.insertOne(res, nomeDb, "dispense", { nome: req.body.nomeDispensa, elementi: [], creatore: req.body.uid }, function (dispense) {
                mongoFunctions.update(res, nomeDb, "utenti", { _id: req.body.uid }, { $push: { dispense: dispense.insertedId } }, {}, function (data) {
                    res.send(JSON.stringify({ errore: false, idDispensa: dispense.insertedId, nome: req.body.nomeDispensa }));
                });
            });
        else {
            res.send(JSON.stringify({ errore: true, messaggio: "Inserire un nome diverso, la dispensa è già presente!" }));
        }
    });
});

//? lettura di tutte le dispense di un utente
app.post("/leggiIdDispense", function (req, res) {
    mongoFunctions.find(res, nomeDb, "utenti", { _id: req.body.uid }, { dispense: 1 }, function (data) {
        if (data[0]["dispense"] && data[0]["dispense"].length > 0) {
            mongoFunctions.find(res, nomeDb, "dispense", { _id: { $in: data[0]["dispense"] } }, { nome: 1, creatore: 1 }, function (data) {
                res.send(JSON.stringify({ errore: false, dati: data }));
            });
        }
        else {
            res.send(JSON.stringify({ errore: false, dati: [] }));
        }
    });
});

//? Inserimento prodotto dispensa
app.post("/inserisciProdottoDispensa", function (req, res) {
    let dato = {
        idProdotto: new mongo.ObjectId(),
        barcode: req.body.barcode,
        nome: req.body.nome,
        dataInserimento: new Date(Date.now()),
        dataScadenza: new Date(req.body.dataScadenza),
        idUtente: req.body.uid,
        qta: req.body.qta
    };
    //? Con upsert se esiste fa l'update se non esiste lo inserisce
    mongoFunctions.update(res, nomeDb, "dispense", { _id: mongo.ObjectID(req.body.idDispensa) }, { $push: { "elementi": dato } }, {}, function (data) {
        res.send(JSON.stringify({ errore: false }));
    });
});

//? Aggiornamento dati relativi ad un prodotto nella dispensa
app.post("/aggiornaProdottoDispensa", function (req, res) {
    mongoFunctions.update(res, nomeDb, "dispense", { _id: mongo.ObjectId(req.body.idDispensa), "elementi.idProdotto": mongo.ObjectId(req.body.idProdotto) }, { $set: { "elementi.$.qta": req.body.qta } }, {}, function (data) {
        res.send(JSON.stringify({ errore: false }));
    });
});

//? Lettura elementi dentro una dispensa
app.post("/leggiDispensa", function (req, res) {
    if (req.body.idDispensa != "default") {
        mongoFunctions.find(res, nomeDb, "dispense", { _id: mongo.ObjectID(req.body.idDispensa) }, { elementi: 1 }, function (data) {
            res.send(JSON.stringify({ errore: false, prodotti: data[0]["elementi"] }));
        });
    }
    else {
        mongoFunctions.find(res, nomeDb, "utenti", { _id: req.body.uid }, { dispense: 1 }, function (data) {
            mongoFunctions.find(res, nomeDb, "dispense", { _id: mongo.ObjectID(data[0]["dispense"][0]) }, { elementi: 1 }, function (data) {
                res.send(JSON.stringify({ errore: false, prodotti: data[0]["elementi"] }));
            });
        });
    }
});

app.post("/eliminaDispensa", function (req, res) {
    mongoFunctions.update(res, nomeDb, "utenti", { _id: req.body.uid }, { $pull: { dispense: mongo.ObjectID(req.body.idDispensa) } }, {}, function (data) {
        mongoFunctions.deleteMany(res, nomeDb, "dispense", { _id: mongo.ObjectID(req.body.idDispensa), creatore: req.body.uid }, function (data) {
            res.send(JSON.stringify({ errore: false }));
        });
    });
});

app.post("/eliminaProdottoDispensa", function (req, res) {
    mongoFunctions.update(res, nomeDb, "dispense", { _id: mongo.ObjectID(req.body.idDispensa) }, { $pull: { elementi: { idProdotto: mongo.ObjectID(req.body.idProdotto) } } }, {}, function (data) {
        res.send(JSON.stringify({ errore: false }));
    });
});

//? aggiornamento nome della dispensa
app.post("/aggiornaDispensa", function (req, res) {
    mongoFunctions.update(res, nomeDb, "dispense", { _id: mongo.ObjectID(req.body.idDispensa) }, { $set: { nome: req.body.nomeDispensa } }, {}, function (data) {
        res.send(JSON.stringify({ errore: false }));
    });
});

//#endregion
//#endregion

//#region FUNZIONI AGGIUNTIVE
function auto() {
    //? scorrere tutti gli utenti
    //? scorrere tutte le liste di ogni utente
    //? scorrere tutti i prodotti di ogni utente e trovare quelli in scandenza
    //? mandare la notifica sui prodotti in scadenza entro un giorno
    let res = null;
    mongoFunctions.find(res, nomeDb, "utenti", {}, {}, function (utenti) {
        utenti.forEach(utente => {
            utente.dispense.forEach(idDispensa => {
                mongoFunctions.find(res, nomeDb, "dispense", { _id: mongo.ObjectID(idDispensa), }, { elementi: 1 }, function (prodotti) {
                    prodotti[0].elementi.forEach(prodotto => {
                        //? 24h in millisecondi
                        if ((prodotto.dataScadenza - Date.now()) < 86400000) {
                            var message = {
                                data: {
                                    nome: getProductName(),
                                    quantità: prodotto.qta,
                                    dataScadenza: new Date(prodotto.dataScadenza)
                                }
                            };
                            sendNotification(utente._id, message);
                        }
                    });
                });
            });
        });
    });
}

function sendNotification(id, message) {
    // This registration token comes from the client FCM SDKs.
    mongoFunctions.find(res, nomeDb, "utenti", { _id: mongo.ObjectID(id) }, { tokenFCM: 1 }, function (data) {
        message.token = data[0].tokenFCM;
    });

    // Send a message to the device corresponding to the provided
    // registration token.
    admin.messaging().send(message)
        .then((response) => {
            // Response is a message ID string.
            console.log('Successfully sent message:', response);
        })
        .catch((error) => {
            console.log('Error sending message:', error);
        });
}

function getProductName(code) {
    request('https://it.openfoodfacts.org/api/v0/product/' + code + '.json', async function (error, response, body) {
        if (!error && response.statusCode == 200) {
            body = JSON.parse(body);
            //? Controllo se il risultato è valido oppure no
            if (body.status != 0)
                return body.product.product_name; //?nome del prodotto
            else
                return "";
        }
        else
            return "";
    });
}

//#endregion