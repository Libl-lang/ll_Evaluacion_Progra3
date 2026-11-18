package examen.veterinaria.repository;

import examen.veterinaria.config.ConexionBD;
import examen.veterinaria.model.Cliente;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class RepositorioClienteMySQL implements RepositorioCliente {

    @Override
    public List<Cliente> cargarTodos() {
        List<Cliente> clientes = new ArrayList<>();

        String sql = "{CALL sp_listar_clientes()}";

        try (
                Connection conexion = ConexionBD.obtenerConexion();
                CallableStatement llamada = conexion.prepareCall(sql);
                ResultSet resultado = llamada.executeQuery()
        ) {
            while (resultado.next()) {
                Cliente cliente = new Cliente(
                        resultado.getString("cedula"),
                        resultado.getString("nombre"),
                        resultado.getString("telefono")
                );

                clientes.add(cliente);
            }

            return clientes;

        } catch (SQLException e) {
            throw new PersistenciaException(
                    "No se pudieron cargar los clientes desde MySQL: " + e.getMessage(),
                    e
            );
        }
    }

    @Override
    public void insertar(Cliente cliente) {
        String sql = "{CALL sp_insertar_cliente(?, ?, ?, ?)}";

        if (cliente.getEdad() == null) {
            throw new IllegalArgumentException(
                    "Debe indicar la edad del cliente."
            );
        }

        try (
                Connection conexion = ConexionBD.obtenerConexion();
                CallableStatement llamada = conexion.prepareCall(sql)
        ) {
            llamada.setString(1, cliente.getCedula());
            llamada.setString(2, cliente.getNombre());
            llamada.setString(3, cliente.getTelefono());
            llamada.setInt(4, cliente.getEdad());

            llamada.execute();

        } catch (SQLException e) {
            throw new PersistenciaException(
                    "No se pudo insertar el cliente en MySQL: " + e.getMessage(),
                    e
            );
        }
    }
}
