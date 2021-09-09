var getData = function () {
    var code = document.getElementById("code").value;
    var HasCachedAcl = document.getElementById("HasCachedAcl").value;
    var idRegistro = document.getElementById("idRegistro").value;
    var IsRemoved = document.getElementById("IsRemoved").value;
    var Name = document.getElementById("Name").value;
    var Reference = document.getElementById("Reference").value;
    var Schemas = document.getElementById("Schemas").value;

    console.log(code,HasCachedAcl,idRegistro,IsRemoved,Name,Reference,Schemas);

    app.createRegistro(code,HasCachedAcl,idRegistro,IsRemoved,Name,Reference,Schemas);
}
var buscarPorId = function () {
    var idRegistro = document.getElementById("idRegistro2").value;
    console.log(idRegistro);
    app.buscarRegristroPorId(idRegistro);
}
var buscarPorNombre = function () {
    var idRegistro = document.getElementById("idRegistro2").value;
    console.log(idRegistro);
    app.buscarPorNombre(idRegistro);
}