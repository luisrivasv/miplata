# MiPlata

Primera versión de MiPlata: una PWA para probar el flujo de cuentas, movimientos, tarjetas, compromisos y ahorro familiar.

## Estado actual

- Interfaz adaptable a iPhone y escritorio.
- Navegación entre Inicio/Mi dinero, Mis tarjetas, Próximos pagos y Ahorro familiar.
- Registro de movimientos y compromisos en la interfaz.
- Datos ficticios precargados para probar el flujo.
- Guarda el estado de demostración en el almacenamiento local del navegador.
- Manifiesto y service worker iniciales para instalación como PWA.

## Importante

Esta versión **no tiene inicio de sesión, no sincroniza entre personas y no se conecta a bancos**. Los datos son de demostración y el almacenamiento local no es una base de datos compartida ni una copia de seguridad. No ingreses datos financieros reales todavía. Antes de utilizar información real hay que implementar autenticación, base de datos, reglas de acceso, privacidad y copias de seguridad.

## Publicar con GitHub Pages

1. En el repositorio abre **Settings → Pages**.
2. En “Build and deployment”, selecciona **Deploy from a branch**, rama `main`, carpeta `/ (root)` y guarda.
3. Espera a que GitHub complete el despliegue. La URL tendrá la forma `https://luisrivasv.github.io/miplata/`.

## Añadir a la pantalla de inicio en iPhone

Abre la URL publicada en Safari, pulsa **Compartir** y elige **Añadir a pantalla de inicio**.

## Próximas tareas

1. Validar los cálculos de saldos, transferencias internas, reservas y deuda de tarjetas.
2. Añadir exportación e importación de Excel.
3. Conectar autenticación y base de datos segura para separar finanzas personales de las compartidas.
4. Probar permisos y copias de seguridad antes de cargar datos reales.
