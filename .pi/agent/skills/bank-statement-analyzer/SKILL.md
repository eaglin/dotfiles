---
name: bank-statement-analyzer
description: Analiza extractos bancarios en Excel (.xls/.xlsx) y PDF y genera un resumen de gastos agrupado por concepto/comercio, con totales, nº de operaciones y desglose por periodo de facturación. Soporta múltiples ficheros a la vez, deduplicación automática de PDFs y exportación a Excel.
---

# Bank Statement Analyzer

Analiza ficheros Excel (.xls/.xlsx) y PDF de movimientos de tarjeta de crédito/débito y produce un resumen de gastos agrupado por concepto o comercio, con número de operaciones, total en euros y desglose por periodo de facturación.

## Cuándo usarlo

Cuando el usuario tenga ficheros Excel y/o PDF con movimientos bancarios y quiera:
- Ver un resumen de gastos agrupado por comercio/concepto
- Saber cuánto se ha gastado en total y por periodo de facturación
- Combinar varios extractos (Excel + PDF) en un solo análisis
- Exportar el resultado a Excel

## Cómo ejecutarlo

El script está en:
```
~/.pi/agent/skills/bank-statement-analyzer/analyze_bank_statements.py
```

### Uso básico (un fichero Excel)

```bash
python3 ~/.pi/agent/skills/bank-statement-analyzer/analyze_bank_statements.py ~/Downloads/movimientos.xls
```

### Múltiples ficheros (Excel + PDF mezclados)

```bash
python3 ~/.pi/agent/skills/bank-statement-analyzer/analyze_bank_statements.py \
  ~/Downloads/*.pdf ~/Downloads/movimientos.xls ~/Downloads/movimientosExtracto.xls
```

### Con wildcards

```bash
# Todos los Excel de Downloads
python3 ~/.pi/agent/skills/bank-statement-analyzer/analyze_bank_statements.py "~/Downloads/movim*.xls"

# Todos los PDF y Excel de Downloads
python3 ~/.pi/agent/skills/bank-statement-analyzer/analyze_bank_statements.py ~/Downloads/*.pdf ~/Downloads/*.xls
```

### Exportar resultado a Excel

```bash
python3 ~/.pi/agent/skills/bank-statement-analyzer/analyze_bank_statements.py \
  ~/Downloads/*.pdf ~/Downloads/*.xls --output ~/Downloads/resumen_gastos.xlsx
```

### Incluir pagos de recibos del mes anterior en el resumen

```bash
python3 ~/.pi/agent/skills/bank-statement-analyzer/analyze_bank_statements.py ~/Downloads/movimientos.xls --include-recibos
```

## Requisitos

El script necesita `pandas`, `openpyxl`, `xlrd` (para Excel) y `pdfplumber` (para PDF). Si no están instalados:

```bash
pip3 install --user --break-system-packages pandas openpyxl xlrd pdfplumber
```

## Formatos soportados

### Excel (.xls / .xlsx)

El script busca automáticamente las columnas por nombre parcial:

| Columna esperada | Palabras clave que busca |
|---|---|
| Fecha de la operación | `fecha` |
| Concepto / Comercio | `concepto` o `comercio` |
| Ciudad | `ciudad` o `localidad` |
| Importe de la operación (€) | `importe` o `operacion` |

### PDF

Soporta extractos de tarjeta WiZink (y compatibles) con:
- Tablas de movimientos con columnas separadas (fecha, concepto, localidad, país, importe)
- Filas colapsadas en una sola celda
- Sección de "Recibos y otros pagos"
- Detección automática del periodo de facturación en la primera página
- **Deduplicación automática**: si hay varios PDFs con el mismo periodo, solo se procesa uno

## Cómo agrupa por periodo de facturación

Cada fichero representa **un periodo de facturación** completo (ej: del 22/05 al 22/06). El script etiqueta el periodo por el **mes de cierre**, no por mes natural:

- Un fichero con fechas del 22/05 al 22/06 → etiquetado como **"Junio 2026"**
- Un fichero con fechas del 22/07 al 16/08 → etiquetado como **"Agosto 2026"**
- Un PDF con "Periodo de facturación: 24/03/2026 - 23/04/2026" → etiquetado como **"24/03/2026 - 23/04/2026"**

Esto evita que un periodo se parta artificialmente entre dos meses.

## Qué hace el script

1. Detecta automáticamente el tipo de fichero (.xls, .xlsx, .pdf)
2. Lee uno o varios ficheros y extrae los movimientos
3. **PDFs**: deduplica automáticamente los que tengan el mismo periodo de facturación
4. Normaliza los nombres de los conceptos (mayúsculas, quita sufijos como "SL")
5. Separa automáticamente los "PAGO RECIBO MES ANTERIOR" de los gastos reales
6. Agrupa por concepto/comercio: nº de operaciones + total en €
7. Genera un desglose de gastos por periodo de facturación
8. (Opcional) Exporta el resultado a un Excel con 3 hojas: resumen por concepto, resumen por periodo y movimientos detallados

## Notas

- Los movimientos de "PAGO RECIBO MES ANTERIOR" se excluyen del subtotal de gastos por defecto (no son gastos reales, sino el pago de la tarjeta del mes anterior)
- El script detecta automáticamente si el fichero es .xls (motor xlrd), .xlsx (motor openpyxl) o .pdf (motor pdfplumber)
- Al combinar varios ficheros, los movimientos se concatenan y se agrupan juntos
- Los PDFs se ordenan cronológicamente junto con los Excel en el desglose por periodo