// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title SistemaVotacion
 * @dev Un contrato simple para gestionar una votación entre dos opciones
 */
contract SistemaVotacion {
    // Estructura para almacenar la información de cada votante
    struct Votante {
        bool haVotado;  // Si el votante ya ha emitido su voto
        uint opcion;    // La opción que eligió (1 para A, 2 para B)
    }

    // La persona que crea el contrato se convierte en el administrador
    address public administrador;
    
    // Mapa que registra los votantes por su dirección
    mapping(address => Votante) public votantes;
    
    // Contadores de votos para cada opción
    uint public contadorOpcionA;
    uint public contadorOpcionB;
    
    // El periodo de votación
    uint public inicioVotacion;
    uint public finVotacion;
    
    // Estado de la votación
    bool public votacionCerrada;
    
    // Eventos para registrar acciones importantes en la blockchain
    event VotoEmitido(address votante, uint opcion);
    event VotacionFinalizada(uint totalOpcionA, uint totalOpcionB);

    /**
     * @dev Constructor que establece el administrador y el tiempo de votación
     * @param _duracionEnMinutos duración de la votación en minutos
     */
    constructor(uint _duracionEnMinutos) {
        administrador = msg.sender;
        inicioVotacion = block.timestamp;
        finVotacion = inicioVotacion + (_duracionEnMinutos * 1 minutes);
        votacionCerrada = false;
    }

    /**
     * @dev Permite a un usuario votar por una opción
     * @param _opcion La opción elegida (1 para A, 2 para B)
     */
    function votar(uint _opcion) public {
        // Verificar que la votación esté activa
        require(block.timestamp >= inicioVotacion, "La votacion aun no ha comenzado");
        require(block.timestamp <= finVotacion, "La votacion ha finalizado");
        require(!votacionCerrada, "La votacion ya ha sido cerrada por el administrador");
        
        // Verificar que el votante no haya votado antes
        require(!votantes[msg.sender].haVotado, "Ya has votado");
        
        // Verificar que la opción sea válida
        require(_opcion == 1 || _opcion == 2, "Opcion invalida: debes elegir 1 (A) o 2 (B)");
        
        // Registrar el voto
        votantes[msg.sender].haVotado = true;
        votantes[msg.sender].opcion = _opcion;
        
        // Incrementar el contador de la opción elegida
        if (_opcion == 1) {
            contadorOpcionA++;
        } else {
            contadorOpcionB++;
        }
        
        // Emitir evento de voto
        emit VotoEmitido(msg.sender, _opcion);
    }
    
    /**
     * @dev Permite al administrador cerrar la votación anticipadamente
     */
    function cerrarVotacion() public {
        require(msg.sender == administrador, "Solo el administrador puede cerrar la votacion");
        require(!votacionCerrada, "La votacion ya ha sido cerrada");
        
        votacionCerrada = true;
        emit VotacionFinalizada(contadorOpcionA, contadorOpcionB);
    }
    
    /**
     * @dev Obtiene los resultados actuales de la votación
     * @return Contadores para ambas opciones
     */
    function verResultados() public view returns (uint, uint) {
        return (contadorOpcionA, contadorOpcionB);
    }
    
    /**
     * @dev Verifica si un votante específico ya ha votado
     * @param _votante La dirección del votante a verificar
     * @return Si el votante ha votado
     */
    function haVotado(address _votante) public view returns (bool) {
        return votantes[_votante].haVotado;
    }
    
    /**
     * @dev Verifica por qué opción votó una dirección específica
     * @param _votante La dirección del votante a verificar
     * @return La opción elegida (0 si no ha votado, 1 para A, 2 para B)
     */
    function opcionElegida(address _votante) public view returns (uint) {
        if (!votantes[_votante].haVotado) {
            return 0; // No ha votado
        }
        return votantes[_votante].opcion;
    }
}
