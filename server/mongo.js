var url;
var mongoClient;

module.exports.settings = function settings(_url, _mongoClient) {
    url = _url;
    mongoClient = _mongoClient;
}

module.exports.cont = function cont(res, nomeDb, collezione, query, callback) {
    apriConnessione(res, nomeDb, function (connessione, database) {
        database.collection(collezione).countDocuments(query, function (err, risposta) {
            if (err) errore(res, "ContDocuments", err);
            else {
                callback(risposta);
            }
            connessione.close();
        });
    });
}

module.exports.aggregate = function aggregate(res, nomeDb, collezione, options, callback) {
    apriConnessione(res, nomeDb, function (connessione, database) {
        database.collection(collezione).aggregate(options).toArray(function (err, risposta) {
            if (err) errore(res, "Aggregate", err);
            else {
                callback(risposta);
            }
            connessione.close();
        });
    });
}

module.exports.find = function find(res, nomeDb, collezione, query, select, callback) {
    apriConnessione(res, nomeDb, function (connessione, database) {
        database.collection(collezione).find(query).project(select).toArray(function (err, risposta) {
            if (err) errore(res, "Find", err);
            else {
                callback(risposta);
            }
            connessione.close();
        });
    });
}

module.exports.insert = function insert(res, nomeDb, collezione, elems, callback) {
    apriConnessione(res, nomeDb, function (connessione, database) {
        database.collection(collezione).insertMany(elems, function (err, risposta) {
            if (err) errore(res, "Insert", err);
            else {
                callback(risposta);
            }
            connessione.close();
        });
    });
}

module.exports.findAndUpdate = function findAndUpdate(res, nomeDb, collezione, condizione, elems, options, callback) {
    apriConnessione(res, nomeDb, function (connessione, database) {
        database.collection(collezione).findOneAndUpdate(condizione, elems, options, function (err, risposta) {
            if (err) errore(res, "Find and update", err);
            else {
                callback(risposta);
            }
            connessione.close();
        });
    });
}

module.exports.update = function update(res, nomeDb, collezione, condizione, elems, options, callback) {
    apriConnessione(res, nomeDb, function (connessione, database) {
        database.collection(collezione).updateMany(condizione, elems, options, function (err, risposta) {
            if (err) errore(res, "Update", err);
            else {
                callback(risposta);
            }
            connessione.close();
        });
    });
}

module.exports.deleteMany = function deleteMany(res, nomeDb, collezione, condizione, callback) {
    apriConnessione(res, nomeDb, function (connessione, database) {
        database.collection(collezione).deleteMany(condizione, function (err, risposta) {
            if (err) errore(res, "Delete", err);
            else {
                callback(risposta);
            }
            connessione.close();
        });
    });
}

function apriConnessione(response, nomeDb, callback) {
    mongoClient.connect(url, { useUnifiedTopology: true }, function (err, connessione) {
        if (err) errore(response, "Connect", err);
        else {
            let database = connessione.db(nomeDb);
            callback(connessione, database);
        }
    });
}

function errore(res, tipo, err) {
    console.log("!MONGO ERROR FUNCTION: " + tipo + " - " + err.toString());
    res.end(JSON.stringify({ errore: true }));
}