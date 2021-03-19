var url;
var mongoClient;

module.exports.settings = function settings(_url, _mongoClient) {
    url = _url;
    mongoClient = _mongoClient;
}

module.exports.cont = function cont(res, nomeDb, collezione, query, callback) {
    apriConnessione(res, nomeDb, function (connessione, database) {
        database.collection(collezione).countDocuments(query, function (err, risposta) {
            if (err) errore(res, "ContDocuments");
            else {
                callback(risposta);
            }
            //connessione.close();
        });
    });
}

module.exports.aggregate = function aggregate(res, nomeDb, collezione, options, callback) {
    apriConnessione(res, nomeDb, function (connessione, database) {
        database.collection(collezione).aggregate(options).toArray(function (err, risposta) {
            if (err) errore(res, "Aggregate");
            else {
                callback(risposta);
            }
            //connessione.close();
        });
    });
}

module.exports.find = function find(res, nomeDb, collezione, query, select, callback) {
    apriConnessione(res, nomeDb, function (connessione, database) {
        database.collection(collezione).find(query).project(select).toArray(function (err, risposta) {
            if (err) errore(res, "Find");
            else {
                callback(risposta);
            }
            //connessione.close();
        });
    });
}

module.exports.insert = function insert(res, nomeDb, collezione, elems, callback) {
    apriConnessione(res, nomeDb, function (connessione, database) {
        database.collection(collezione).insertMany(elems, function (err, risposta) {
            if (err) errore(res, "Insert");
            else {
                callback(risposta);
            }
            //connessione.close();
        });
    });
}

module.exports.update = function update(res, nomeDb, collezione, condizione, elems, callback) {
    apriConnessione(res, nomeDb, function (connessione, database) {
        database.collection(collezione).updateMany(condizione, elems, function (err, risposta) {
            if (err) errore(res, "Insert");
            else {
                callback(risposta);
            }
            //connessione.close();
        });
    });
}

function apriConnessione(response, nomeDb, callback) {
    mongoClient.connect(url, { useUnifiedTopology: true }, function (err, connessione) {
        if (err) errore(response, "Connect");
        else {
            let database = connessione.db(nomeDb);
            callback(connessione, database);
        }
    });
}

function errore(res, tipo) {
    console.log(tipo + ": Errore di connessione a mongodb");
    res.end(tipo + ": Errore di connessione a mongodb");
}