
package examen.veterinaria.repository;

import examen.veterinaria.config.ConexionBD;
import examen.veterinaria.model.Especie;
import examen.veterinaria.model.Mascota;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class RepositorioMascotaMySQL implements RepositorioMascota {

    @Override
    public List<Mascota> cargarTodos() {
        List<Mascota> mascotas = new ArrayList<>();

        String sql = "{CALL sp_listar_mascotas()}";

        try (
                Connection conexion = ConexionBD.obtenerConexion();
                CallableStatement llamada = conexion.prepareCall(sql);
                ResultSet resultado = llamada.executeQuery()
        ) {
            while (resultado.next()) {
                Mascota mascota = new Mascota(
                        resultado.getString("codigo"),
                        resultado.getString("nombre"),
                        Especie.valueOf(resultado.getString("especie")),
                        resultado.getInt("edad"),
                        resultado.getString("cedula_cliente")
                );

                mascotas.add(mascota);
            }

            return mascotas;

        } catch (SQLException | IllegalArgumentException e) {
            throw new PersistenciaException(
                    "No se pudieron cargar las mascotas desde MySQL: " + e.getMessage(),
                    e
            );
        }
    }

    @Override
    public void insertar(Mascota mascota) {
        String sql = "{CALL sp_insertar_mascota(?, ?, ?, ?, ?)}";

        try (
                Connection conexion = ConexionBD.obtenerConexion();
                CallableStatement llamada = conexion.prepareCall(sql)
        ) {
            llamada.setString(1, mascota.getCodigo());
            llamada.setString(2, mascota.getNombre());
            llamada.setString(3, mascota.getEspecie().name());
            llamada.setInt(4, mascota.getEdad());
            llamada.setString(5, mascota.getCedulaCliente());

            llamada.execute();

        } catch (SQLException e) {
            throw new PersistenciaException(
                    "No se pudo insertar la mascota en MySQL: " + e.getMessage(),
                    e
            );
        }
    }

    @Override
    public void actualizar(Mascota mascota) {
        String sql = "{CALL sp_actualizar_mascota(?, ?, ?, ?, ?)}";

        try (
                Connection conexion = ConexionBD.obtenerConexion();
                CallableStatement llamada = conexion.prepareCall(sql)
        ) {
            llamada.setString(1, mascota.getCodigo());
            llamada.setString(2, mascota.getNombre());
            llamada.setString(3, mascota.getEspecie().name());
            llamada.setInt(4, mascota.getEdad());
            llamada.setString(5, mascota.getCedulaCliente());

            llamada.execute();

        } catch (SQLException e) {
            throw new PersistenciaException(
                    "No se pudo actualizar la mascota en MySQL: " + e.getMessage(),
                    e
            );
        }
    }

    @Override
    public void eliminar(String codigo) {
        String sql = "{CALL sp_eliminar_mascota(?)}";

        try (
                Connection conexion = ConexionBD.obtenerConexion();
                CallableStatement llamada = conexion.prepareCall(sql)
        ) {
            llamada.setString(1, codigo);

            llamada.execute();

        } catch (SQLException e) {
            throw new PersistenciaException(
                    "No se pudo eliminar la mascota en MySQL: " + e.getMessage(),
                    e
            );
        }
    }

    @Override
    public List<String> listarConDueno() {
        List<String> filas = new ArrayList<>();

        String sql = "{CALL sp_listar_mascotas_con_dueno()}";

        try (
                Connection conexion = ConexionBD.obtenerConexion();
                CallableStatement llamada = conexion.prepareCall(sql);
                ResultSet resultado = llamada.executeQuery()
        ) {
            while (resultado.next()) {
                String fila = String.format(
                        "%s | %s | %s | %d años | Dueño: %s (%s)",
                        resultado.getString("codigo"),
                        resultado.getString("nombre"),
                        resultado.getString("especie"),
                        resultado.getInt("edad"),
                        resultado.getString("cedula_cliente"),
                        resultado.getString("nombre_cliente")
                );

                filas.add(fila);
            }

            return filas;

        } catch (SQLException e) {
            throw new PersistenciaException(
                    "No se pudieron listar las mascotas con su dueño: " + e.getMessage(),
                    e
            );
        }
    }
}
