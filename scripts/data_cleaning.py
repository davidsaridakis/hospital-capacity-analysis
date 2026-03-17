"""
Data Cleaning Pipeline

Author: David Saridakis
Project: hospital-capacity-analysis

Description
-----------
This module contains the data cleaning pipeline used to process the
Spanish National Catalogue of Hospitals dataset.

The cleaned dataset is used for downstream analysis, SQL database
storage, and dashboard visualisation.

Pipeline Steps
--------------
1. Standardise column names (lowercase, snake_case).
2. Rename key fields for clarity.
3. Handle missing values in complex identifiers.
4. Remove redundant administrative codes.
5. Validate dataset integrity.

Usage
-----

Import in notebooks:

    from scripts.data_cleaning import clean_hospital_data

Run as standalone script:

    python scripts/data_cleaning.py

Output
------

Cleaned dataset exported to:

    data/cleaned/hospitals_clean.csv
"""

# Import libraries
import pandas as pd
from pathlib import Path


def clean_hospital_data(df: pd.DataFrame) -> pd.DataFrame:

    # Formatting (snake_case)
    df.columns = (
        df.columns
        .str.lower()
        .str.strip()
        .str.replace(" ", "_")
        .str.replace("ó", "o")
        .str.replace("í", "i")
        .str.replace("á", "a")
        .str.replace(".", "", regex=False)
    )

    # Rename key columns
    df = df.rename(columns={
        "nombre_centro": "hospital_name",
        "direccion": "address",
        "telefono": "phone",
        "municipio": "municipality",
        "provincia": "province",
        "ccaa": "autonomous_community",
        "codigo_postal": "postal_code",
        "camas": "beds",
        "dependencia_funcional": "management_type",
        "clase_de_centro": "center_type"
    })

    # Standardise text fields
    text_cols = [
        'hospital_name',
        'address',
        'municipality',
        'province',
        'autonomous_community',
        'management_type',
        'center_type'
    ]

    for col in text_cols:
        df[col] = (
            df[col]
            .astype(str)
            .str.strip()
            .str.lower()
        )


    # Handle missing values
    df["nombre_del_complejo"] = df["nombre_del_complejo"].fillna("Independent")


    # Fix data types

    # Complex ID ('codidcom') converted to float due 
    # to missing values. Convert to integer where possible.
    df['codidcom'] = df['codidcom'].fillna(0).astype(int)

    # Ensure 'beds' column is numeric
    df['beds'] = pd.to_numeric(df['beds'])

    # Remove unnecessary columns
    df = df.drop(columns=[
        "codcnh",
        "cod_municipio",
        "cod_provincia",
        "cod_ccaa"
    ])

    # Data validatioin checks
    assert df['beds'].min() >= 0, "Invalid bed counts detected"

    assert df['hospital_name'].isnull().sum() == 0, (
        "Hospital name contains null values.."
    )

    return df


if __name__ == "__main__":

    BASE_DIR = Path(__file__).resolve().parents[1]

    raw_path = BASE_DIR / "data/raw/hospitales_spain_raw.xlsx"
    output_path = BASE_DIR / "data/cleaned/hospitals_clean.csv"

    df = pd.read_excel(raw_path)

    df_clean = clean_hospital_data(df)

    df_clean.to_csv(output_path, index=False)

    print("Clean dataset exported.")