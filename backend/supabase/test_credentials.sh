#!/bin/bash

echo "=== PRUEBA DE CREDENCIALES DEL SISTEMA TFG ==="
echo ""

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para probar login
test_login() {
    local email=$1
    local password=$2
    local role=$3
    
    echo -e "${YELLOW}Probando login para: $email (Rol: $role)${NC}"
    
    result=$(psql postgresql://postgres:postgres@127.0.0.1:54322/postgres -t -c "SELECT login_user('$email', '$password');" 2>/dev/null)
    
    if [[ $result == *"success"*"true"* ]]; then
        echo -e "${GREEN}✅ Login exitoso para $email${NC}"
        echo "   Resultado: $result"
    else
        echo -e "${RED}❌ Login fallido para $email${NC}"
        echo "   Resultado: $result"
    fi
    echo ""
}

echo "=== CREDENCIALES DISPONIBLES ==="
echo ""

# Probar credenciales de tutores
test_login "maria.garcia@cifpcarlos3.es" "tutor123" "Tutor"
test_login "carlos.rodriguez@cifpcarlos3.es" "tutor123" "Tutor"
test_login "ana.martinez@cifpcarlos3.es" "tutor123" "Tutor"

# Probar credenciales de estudiantes
test_login "sofia.jimenez@alumno.cifpcarlos3.es" "student123" "Estudiante"
test_login "david.sanchez@alumno.cifpcarlos3.es" "student123" "Estudiante"
test_login "juan.perez@alumno.cifpcarlos3.es" "student123" "Estudiante"
test_login "laura.fernandez@alumno.cifpcarlos3.es" "student123" "Estudiante"
test_login "miguel.lopez@alumno.cifpcarlos3.es" "student123" "Estudiante"

# Probar credenciales de administrador
test_login "admin@cifpcarlos3.es" "admin123" "Administrador"

echo "=== FIN DE PRUEBAS ==="

