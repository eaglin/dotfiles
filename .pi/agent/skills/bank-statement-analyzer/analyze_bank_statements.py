#!/usr/bin/env python3
"""
Analizador de extractos bancarios en formato Excel (.xls/.xlsx) y PDF.

Uso:
    python3 analyze_bank_statements.py <fichero1> [fichero2 ...] [--output resultado.xlsx]

Procesa uno o varios ficheros Excel (.xls/.xlsx) y/o PDF de movimientos de
tarjeta, agrupa por concepto/comercio y genera:
  1. Una tabla resumen por concepto (nº operaciones + total)
  2. Un desglose por periodo de facturación
  3. (Opcional) Un Excel de salida con la tabla agrupada

Formato esperado del Excel de entrada:
  - Columna 'Fecha de la operación' (DD/MM/YYYY)
  - Columna 'Concepto / Comercio'
  - Columna 'Ciudad'
  - Columna 'Importe de la operación (€)'

Formato esperado del PDF de entrada:
  - Extracto de tarjeta WiZink (o compatible) con tablas de movimientos
  - El script detecta automáticamente el periodo de facturación en la primera página
  - Soporta filas en columnas separadas y filas colapsadas en una sola celda
  - Deduplica automáticamente PDFs con el mismo periodo de facturación
"""

import sys
import os
import re
import argparse
import glob
from collections import defaultdict

try:
    import pandas as pd
except ImportError:
    print("Error: pandas no está instalado. Ejecuta: pip3 install pandas openpyxl xlrd")
    sys.exit(1)


# ============================================================
#  UTILIDADES COMUNES
# ============================================================

MESES_ES = {
    1: 'Enero', 2: 'Febrero', 3: 'Marzo', 4: 'Abril',
    5: 'Mayo', 6: 'Junio', 7: 'Julio', 8: 'Agosto',
    9: 'Septiembre', 10: 'Octubre', 11: 'Noviembre', 12: 'Diciembre'
}


# Localidades conocidas que pueden aparecer concatenadas al final del concepto
# en los PDFs. Se eliminan para agrupar correctamente.
LOCALIDADES_CONOCIDAS = [
    'MADRID', 'PONTEVEDRA', 'TORREJON DE A', 'VICENTE MORAL', 'FUENGIROLA',
    'CORONA', 'CORK', 'SUNNYVALE', 'PARQUE OESTE', 'LUXEMBOURG', 'DUBLIN',
    'AMSTERDAM', 'SAN FRANCISCO', 'ARTEIXO', 'HORTALEZA', 'CANILLAS VICENTE MORAL',
    'LONDON', 'BARCELONA', 'SEVILLA', 'VALENCIA', 'BILBAO', 'MALAGA',
    'ZARAGOZA', 'CORUNA', 'A CORUNA', 'VIGO', 'PARLA', 'ALCORCON',
    'MOSTOLES', 'GETAFE', 'LEGANES', 'FUENLABRADA', 'ALCALA DE HENARES',
]
# Ordenar por longitud descendente para que las más largas se matcheen primero
LOCALIDADES_CONOCIDAS.sort(key=len, reverse=True)


def normalize_concept(concepto):
    """Normaliza el nombre del concepto para agrupar variantes."""
    c = str(concepto).strip().upper()
    c = re.sub(r'\s+', ' ', c)
    c = re.sub(r'\s+SL\.?$', '', c)
    c = re.sub(r'\s+S\.L\.U\.?$', '', c)
    # Quitar localidades conocidas al final del concepto (de los PDFs)
    for loc in LOCALIDADES_CONOCIDAS:
        if c.endswith(' ' + loc):
            c = c[:-(len(loc) + 1)].strip()
            break
    return c


def find_column(df, *candidates):
    """Busca una columna por nombre parcial."""
    for col in df.columns:
        col_lower = str(col).lower().strip()
        for candidate in candidates:
            if candidate.lower() in col_lower:
                return col
    return None


def parse_importe_str(s):
    """Convierte un string de importe español (ej: '1.234,56 €') a float."""
    if s is None:
        return None
    s = str(s).strip().replace('€', '').strip()
    if not s:
        return None
    s = s.replace('.', '').replace(',', '.')
    try:
        return float(s)
    except ValueError:
        return None


def label_periodo(fecha_max):
    """Genera una etiqueta de periodo a partir de la fecha de cierre."""
    if pd.isna(fecha_max):
        return "Periodo desconocido"
    return f"{MESES_ES.get(fecha_max.month, str(fecha_max.month))} {fecha_max.year}"


# ============================================================
#  LECTURA DE EXCEL
# ============================================================

def detect_engine(path):
    ext = os.path.splitext(path)[1].lower()
    if ext == '.xlsx':
        return 'openpyxl'
    elif ext == '.xls':
        return 'xlrd'
    return 'xlrd'


def read_excel_safe(path):
    engine = detect_engine(path)
    try:
        return pd.read_excel(path, engine=engine)
    except Exception:
        for eng in ['xlrd', 'openpyxl']:
            try:
                return pd.read_excel(path, engine=eng)
            except Exception:
                continue
    raise ValueError(f"No se pudo leer {path} con ningún motor disponible")


def process_excel(path):
    """Procesa un fichero Excel y devuelve un DataFrame normalizado."""
    df = read_excel_safe(path)

    col_fecha = find_column(df, 'fecha')
    col_concepto = find_column(df, 'concepto', 'comercio')
    col_ciudad = find_column(df, 'ciudad', 'localidad')
    col_importe = find_column(df, 'importe', 'operacion')

    if col_concepto is None or col_importe is None:
        print(f"  ⚠️  {os.path.basename(path)}: no se encontraron columnas de concepto/importe")
        print(f"      Columnas disponibles: {list(df.columns)}")
        return None

    rename_map = {}
    if col_fecha:
        rename_map[col_fecha] = 'fecha'
    rename_map[col_concepto] = 'concepto'
    rename_map[col_importe] = 'importe'
    if col_ciudad:
        rename_map[col_ciudad] = 'ciudad'
    df = df.rename(columns=rename_map)

    df['concepto'] = df['concepto'].astype(str).apply(normalize_concept)
    df['importe'] = pd.to_numeric(df['importe'], errors='coerce').fillna(0)
    df['ciudad'] = df['ciudad'].astype(str).str.strip() if 'ciudad' in df.columns else ''
    if 'fecha' not in df.columns:
        df['fecha'] = ''
    df['fecha_dt'] = pd.to_datetime(df['fecha'], format='%d/%m/%Y', errors='coerce')

    fecha_max = df['fecha_dt'].max()
    df['periodo'] = label_periodo(fecha_max)
    df['fichero'] = os.path.basename(path)

    return df[['fecha', 'concepto', 'ciudad', 'importe', 'periodo', 'fichero', 'fecha_dt']]


# ============================================================
#  LECTURA DE PDF
# ============================================================

def _import_pdfplumber():
    try:
        import pdfplumber
        return pdfplumber
    except ImportError:
        print("Error: pdfplumber no está instalado. Ejecuta: pip3 install pdfplumber")
        sys.exit(1)


def _parse_collapsed_row(cell):
    """Parsea una fila colapsada en una sola celda del PDF."""
    cell = cell.strip()
    # Con país e importe: DD/MM DD/MM CONCEPTO LOCALIDAD PAIS IMPORTE €
    m = re.match(
        r'^(\d{2}/\d{2})\s+(\d{2}/\d{2})\s+(.+?)\s+([A-Z]{2})\s+(-?[\d.]+,\d{2})\s*€?\s*$', cell)
    if m:
        imp = parse_importe_str(m.group(5))
        if imp is not None:
            return m.group(3).strip(), m.group(4), imp
    # Sin país (recibos): DD/MM DD/MM CONCEPTO IMPORTE €
    m2 = re.match(
        r'^(\d{2}/\d{2})\s+(\d{2}/\d{2})\s+(.+?)\s+(-?[\d.]+,\d{2})\s*€?\s*$', cell)
    if m2:
        imp = parse_importe_str(m2.group(4))
        if imp is not None:
            return m2.group(3).strip(), '', imp
    return None


def _extract_pdf_period(pdf):
    """Extrae el periodo de facturación de la primera página del PDF."""
    text0 = pdf.pages[0].extract_text() or ""
    m = re.search(r'Periodo de facturación:\s*(.+)', text0)
    if m:
        return m.group(1).strip()
    return None


def _extract_pdf_rows(pdf):
    """Extrae todas las filas de movimientos de un PDF abierto."""
    rows = []

    for page in pdf.pages:
        text = page.extract_text() or ""
        tables = page.extract_tables()
        page_rows = []

        # Intentar extracción por tablas primero
        for table in tables:
            if not table or len(table) < 2:
                continue
            header = [(h or '').replace('\n', ' ').strip() for h in table[0]]
            ncols = len(header)

            for row in table[1:]:
                if not row or all(c is None for c in row):
                    continue

                # Tabla bien formada (6 columnas)
                if ncols >= 6 and row[0] and row[2] and row[5]:
                    concepto = str(row[2]).strip()
                    if 'Total' in concepto:
                        continue
                    imp = parse_importe_str(row[5])
                    if imp is not None:
                        page_rows.append({'concepto': concepto, 'importe': imp})
                        continue

                # Fila colapsada en una sola celda
                if row[0] and isinstance(row[0], str) and re.match(r'^\d{2}/\d{2}\s+\d{2}/\d{2}', row[0].strip()):
                    res = _parse_collapsed_row(row[0])
                    if res and 'Total' not in res[0]:
                        page_rows.append({'concepto': res[0], 'importe': res[2]})
                    continue

                # Tabla de recibos (4 columnas)
                if ncols == 4 and row[2] and row[3]:
                    concepto = str(row[2]).strip()
                    if 'Total' in concepto:
                        continue
                    imp = parse_importe_str(row[3])
                    if imp is not None:
                        page_rows.append({'concepto': concepto, 'importe': imp})

        # Si las tablas no dieron filas, usar extracción por texto
        if not page_rows:
            for line in text.split('\n'):
                line = line.strip()
                if not line or 'Página' in line or 'Sigue' in line or 'Total' in line:
                    continue
                m = re.match(
                    r'^(\d{2}/\d{2})\s+(\d{2}/\d{2})\s+(.+?)\s+([A-Z]{2})\s+(-?[\d.]+,\d{2})\s*€?\s*$', line)
                if m:
                    imp = parse_importe_str(m.group(5))
                    if imp is not None:
                        page_rows.append({'concepto': m.group(3).strip(), 'importe': imp})
                    continue
                m2 = re.match(
                    r'^(\d{2}/\d{2})\s+(\d{2}/\d{2})\s+(.+?)\s+(-?[\d.]+,\d{2})\s*€?\s*$', line)
                if m2:
                    imp = parse_importe_str(m2.group(4))
                    if imp is not None:
                        page_rows.append({'concepto': m2.group(3).strip(), 'importe': imp})

        rows.extend(page_rows)

    return rows


def process_pdf(path):
    """Procesa un PDF de extracto bancario y devuelve un DataFrame normalizado."""
    pdfplumber = _import_pdfplumber()

    with pdfplumber.open(path) as pdf:
        periodo_str = _extract_pdf_period(pdf)
        raw_rows = _extract_pdf_rows(pdf)

    if not raw_rows:
        print(f"  ⚠️  {os.path.basename(path)}: no se extrajeron movimientos")
        return None

    # Construir DataFrame
    df = pd.DataFrame(raw_rows)
    df['concepto'] = df['concepto'].astype(str).apply(normalize_concept)
    df['importe'] = pd.to_numeric(df['importe'], errors='coerce').fillna(0)
    df['ciudad'] = ''
    df['fecha'] = ''

    # Determinar periodo: extraer la fecha de fin del periodo de facturacion del PDF
    # y generar una etiqueta legible (ej: "Abril 2026"). Si no se puede, usar fallback.
    fecha_cierre = None
    if periodo_str:
        m = re.search(r'(\d{2}/\d{2}/\d{4})\s*$', periodo_str)
        if m:
            fecha_cierre = pd.to_datetime(m.group(1), format='%d/%m/%Y', errors='coerce')
    if fecha_cierre is not None and not pd.isna(fecha_cierre):
        periodo_label = label_periodo(fecha_cierre)
    else:
        periodo_label = 'Periodo desconocido'
    df['periodo'] = periodo_label
    df['fecha_dt'] = fecha_cierre if fecha_cierre is not None else pd.NaT

    df['fichero'] = os.path.basename(path)

    return df[['fecha', 'concepto', 'ciudad', 'importe', 'periodo', 'fichero', 'fecha_dt']]


# ============================================================
#  PROCESAMIENTO PRINCIPAL
# ============================================================

def process_file(path):
    """Detecta el tipo de fichero y lo procesa con el motor adecuado."""
    ext = os.path.splitext(path)[1].lower()

    if ext in ('.xls', '.xlsx'):
        return process_excel(path)
    elif ext == '.pdf':
        return process_pdf(path)
    else:
        print(f"  ⚠️  {os.path.basename(path)}: formato no soportado ({ext})")
        print(f"      Formatos aceptados: .xls, .xlsx, .pdf")
        return None


def deduplicate_pdfs(dfs):
    """Si hay PDFs con el mismo periodo de facturación, se queda solo con el primero."""
    seen_periods = {}
    result = []
    for df in dfs:
        periodo = df['periodo'].iloc[0] if len(df) > 0 else ''
        fichero = df['fichero'].iloc[0] if len(df) > 0 else ''
        if periodo in seen_periods:
            print(f"  ℹ️  Duplicado descartado: {fichero} (mismo periodo que {seen_periods[periodo]})")
        else:
            seen_periods[periodo] = fichero
            result.append(df)
    return result


def group_by_concept(df, exclude_recibos=True):
    """Agrupa por concepto y devuelve un DataFrame ordenado."""
    if exclude_recibos:
        mask = ~df['concepto'].str.contains('PAGO RECIBO', case=False, na=False)
        gastos_df = df[mask]
        recibos_df = df[~mask]
    else:
        gastos_df = df
        recibos_df = df.iloc[0:0]

    g = gastos_df.groupby('concepto')['importe'].agg(['count', 'sum']).reset_index()
    g.columns = ['Concepto / Comercio', 'Nº operaciones', 'Total (€)']
    g = g.sort_values('Total (€)', ascending=False).reset_index(drop=True)

    return g, gastos_df, recibos_df


def group_by_period(df):
    """Agrupa por periodo de facturación y devuelve un DataFrame."""
    g = df.groupby('periodo')['importe'].agg(['count', 'sum']).reset_index()
    g.columns = ['Periodo de facturación', 'Nº operaciones', 'Total (€)']
    # Ordenar: por fecha maxima de cada periodo (fecha de cierre = mes del periodo)
    if 'fecha_dt' in df.columns and df['fecha_dt'].notna().any():
        orden_map = {}
        for periodo in df['periodo'].unique():
            fechas = df[df['periodo'] == periodo]['fecha_dt'].dropna()
            orden_map[periodo] = fechas.max() if len(fechas) > 0 else pd.Timestamp.max
        # Para periodos sin fecha_dt (PDFs), usar el orden alfabético como fallback
        g['_orden'] = g['Periodo de facturación'].map(
            lambda p: orden_map.get(p, pd.Timestamp.max)
        )
    else:
        g['_orden'] = g['Periodo de facturación']
    g = g.sort_values('_orden').drop(columns='_orden').reset_index(drop=True)
    return g


def print_summary(gastos_table, total_gastos, total_ops, recibos_table, total_recibos,
                  period_table, filenames):
    """Imprime el resumen en consola."""
    print()
    print("=" * 72)
    print("  📊 RESUMEN DE GASTOS POR CONCEPTO")
    print("=" * 72)
    print(f"  Ficheros: {', '.join(filenames)}")
    print()

    print(f"  {'#':>3}  {'Concepto':42}  {'Nº':>4}  {'Total (€)':>11}")
    print("  " + "-" * 68)
    for i, row in gastos_table.iterrows():
        print(f"  {i+1:3}  {row['Concepto / Comercio'][:42]:42}  "
              f"{row['Nº operaciones']:4}  {row['Total (€)']:11.2f}")
    print("  " + "-" * 68)
    print(f"  {'':3}  {'SUBTOTAL GASTOS':42}  {total_ops:4}  {total_gastos:11.2f}")

    if len(recibos_table) > 0:
        for _, row in recibos_table.iterrows():
            print(f"  {'':3}  {row['Concepto / Comercio'][:42]:42}  "
                  f"{row['Nº operaciones']:4}  {row['Total (€)']:11.2f}")
        print(f"  {'':3}  {'TOTAL GENERAL':42}  "
              f"{total_ops + recibos_table['Nº operaciones'].sum():4}  "
              f"{total_gastos + total_recibos:11.2f}")
    else:
        print(f"  {'':3}  {'TOTAL GENERAL':42}  {total_ops:4}  {total_gastos:11.2f}")

    print()
    print("  📅 GASTOS POR PERIODO DE FACTURACIÓN")
    print("  " + "-" * 55)
    for _, row in period_table.iterrows():
        print(f"  {row['Periodo de facturación']:25}  {row['Nº operaciones']:4} ops  {row['Total (€)']:10.2f} €")
    print("  " + "-" * 55)
    print(f"  {'TOTAL':25}  {period_table['Nº operaciones'].sum():4} ops  "
          f"{period_table['Total (€)'].sum():10.2f} €")

    print()
    print(f"  Conceptos distintos: {len(gastos_table)}")
    print(f"  Total de operaciones: {total_ops}")
    print(f"  Total gastos: {total_gastos:.2f} €")
    if len(recibos_table) > 0:
        print(f"  Pago recibos mes anterior: {total_recibos:.2f} €")
    print("=" * 72)


def main():
    parser = argparse.ArgumentParser(
        description='Analiza extractos bancarios en Excel (.xls/.xlsx) y PDF, '
                    'agrupa por concepto y por periodo de facturación.'
    )
    parser.add_argument('files', nargs='+',
                        help='Ficheros Excel (.xls/.xlsx) y/o PDF de extractos bancarios')
    parser.add_argument('--output', '-o',
                        help='Fichero Excel de salida con la tabla agrupada')
    parser.add_argument('--include-recibos', action='store_true',
                        help='Incluir PAGO RECIBO MES ANTERIOR en el resumen de gastos')
    args = parser.parse_args()

    # Expandir wildcards
    all_files = []
    for f in args.files:
        expanded = glob.glob(os.path.expanduser(f))
        if expanded:
            all_files.extend(sorted(expanded))
        elif os.path.exists(os.path.expanduser(f)):
            all_files.append(os.path.expanduser(f))
        else:
            print(f"  ⚠️  No se encontró: {f}")

    if not all_files:
        print("Error: No se encontraron ficheros para procesar.")
        sys.exit(1)

    # Procesar todos los ficheros
    all_dfs = []
    pdf_dfs = []
    excel_dfs = []

    for path in all_files:
        ext = os.path.splitext(path)[1].lower()
        print(f"  📄 Procesando: {os.path.basename(path)}...")
        df = process_file(path)
        if df is not None:
            all_dfs.append(df)
            if ext == '.pdf':
                pdf_dfs.append(df)
            else:
                excel_dfs.append(df)
            print(f"     → {len(df)} movimientos  ({df['periodo'].iloc[0]})")

    if not all_dfs:
        print("Error: No se pudieron procesar los ficheros.")
        sys.exit(1)

    # Deduplicar PDFs con el mismo periodo
    if len(pdf_dfs) > 1:
        before = sum(len(df) for df in pdf_dfs)
        pdf_dfs = deduplicate_pdfs(pdf_dfs)
        after = sum(len(df) for df in pdf_dfs)
        if before != after:
            print(f"\n  ℹ️  PDFs deduplicados: {before} → {after} movimientos")

    # Recombinar todo
    combined = pd.concat(pdf_dfs + excel_dfs, ignore_index=True)
    print(f"\n  Total movimientos combinados: {len(combined)}")

    # Agrupar
    gastos_table, gastos_df, recibos_df = group_by_concept(
        combined, exclude_recibos=not args.include_recibos)
    period_table = group_by_period(gastos_df)

    # Totales
    total_gastos = gastos_table['Total (€)'].sum()
    total_ops = gastos_table['Nº operaciones'].sum()

    # Recibos
    if len(recibos_df) > 0:
        recibos_table = recibos_df.groupby('concepto')['importe'].agg(['count', 'sum']).reset_index()
        recibos_table.columns = ['Concepto / Comercio', 'Nº operaciones', 'Total (€)']
        total_recibos = recibos_table['Total (€)'].sum()
    else:
        recibos_table = pd.DataFrame(columns=['Concepto / Comercio', 'Nº operaciones', 'Total (€)'])
        total_recibos = 0

    # Imprimir resumen
    print_summary(gastos_table, total_gastos, total_ops, recibos_table, total_recibos,
                  period_table, [os.path.basename(f) for f in all_files])

    # Exportar a Excel si se solicita
    if args.output:
        output_path = os.path.expanduser(args.output)
        with pd.ExcelWriter(output_path, engine='openpyxl') as writer:
            gastos_table.to_excel(writer, sheet_name='Resumen por concepto', index=False)
            period_table.to_excel(writer, sheet_name='Resumen por periodo', index=False)
            combined.to_excel(writer, sheet_name='Movimientos detallados', index=False)
        print(f"\n  ✅ Excel generado: {output_path}")


if __name__ == '__main__':
    main()