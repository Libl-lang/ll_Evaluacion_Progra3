package examen.veterinaria.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class ConexionBD {

    public static Connection obtenerConexion() throws SQLException {

        String url = System.getenv("VET_DB_URL");
        String usuario = System.getenv("VET_DB_USER");
        String password = System.getenv("VET_DB_PASSWORD");

        if (url == null || usuario == null || password == null) {
            throw new SQLException(
                    "Faltan variables de entorno para conectar con MySQL."
            );
        }

        return DriverManager.getConnection(url, usuario, password);
    }
}