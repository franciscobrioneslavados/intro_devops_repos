import streamlit as st
import plotly.express as px
import pandas as pd

# Configuración inicial de lapágina
st.set_page_config(page_title="Simulador VPC AWS", page_icon="☁️", layout="centered")

st.title("Simulador de Redes VPC")
st.markdown("""
Diseñar una VPC implica dividir su bloque CIDR en subredes de igual tamaño. 
Ajusta los parámetros para simular tu diseño y asegurar que cumpla con los requisitos y mejores prácticas de AWS.
""")

st.divider()

# Formularios en Columnas
col1, col2, col3, col4 = st.columns(4)

with col1:
    vpc_mask = st.number_input("Máscara VPC Base", min_value=16, max_value=28, value=20)
    st.caption("Rango: /16 a /28.")
with col2:
    azs = st.number_input("Zonas (AZ)", min_value=1, max_value=6, value=2)
    st.caption("Nº AZs en la región.")
with col3:
    subnets_per_az = st.number_input("Capas lógicas", min_value=1, max_value=6, value=3)
    st.caption("Ej: Web, App, DB.")
with col4:
    newbits = st.number_input("newbits", min_value=1, max_value=14, value=4)
    st.caption("Bits a sumar a la máscara.")

# Matemáticas Clave
vpc_total_ips = 2 ** (32 - vpc_mask)
total_subnets = 2**newbits
mask = vpc_mask + newbits
ips_per_subnet = 2 ** (32 - mask)

subnets_needed = azs * subnets_per_az
safe_total = 0 if mask > 28 else total_subnets
free_subnets = max(0, safe_total - subnets_needed)

st.markdown("<br>", unsafe_allow_html=True)
st.code(f'cidrsubnet("VPC_BASE", {newbits}, count.index)', language="hcl")

# Estadísticas grandes estilo Dashboard
m1, m2, m3, m4 = st.columns(4)
m1.metric(label="Total de IPs VPC", value=f"{vpc_total_ips:,}")
m2.metric(label="Subnet Mask", value=f"/{mask}")
m3.metric(label="IPs x Subnet", value=f"{ips_per_subnet:,}")
m4.metric(label="Subredes Creadas", value=f"{total_subnets:,}")

st.markdown("<br>", unsafe_allow_html=True)

# Lógica de Validación (Cajas de Error)
has_errors = False
if vpc_mask > 28 or vpc_mask < 16:
    st.error(
        "Error AWS: Las políticas dictan que una VPC debe medir estrictamente entre /16 y /28."
    )
    has_errors = True
elif mask > 28:
    st.error(
        f"Error AWS: Amazon no permite subredes menores a /28 (16 IPs). Tu máscara actual es /{mask}. Disminuye los Newbits o amplía la VPC Base."
    )
    has_errors = True
elif total_subnets < subnets_needed:
    st.error(
        f"Error Terraform: Estás generando {total_subnets} subredes, pero necesitas {subnets_needed} ({azs} zonas x {subnets_per_az} capas). Aumenta los Newbits."
    )
    has_errors = True
elif free_subnets == 0:
    st.warning(
        "Recomendación AWS: Has asignado el 100% del espacio de red. Deja subredes de reserva."
    )
else:
    st.success(
        "Todo correcto: El diseño cumple con AWS y deja margen para expandirse a futuro."
    )

# Gráfico Visual con Plotly
labels = []
values = []
remaining = safe_total

for i in range(subnets_per_az):
    layer_name = (
        "Capa Externa"
        if i == 0
        else "Capa Interna 1"
        if i == 1
        else "Capa Interna 2"
        if i == 2
        else f"Capa Extra {i + 1}"
    )

    used = min(max(0, remaining), azs)

    if (has_errors and total_subnets < subnets_needed) and used < azs:
        labels.append(f"{layer_name} (Faltantes)")
    else:
        labels.append(f"{layer_name}")

    values.append(used)
    remaining -= used

if free_subnets > 0 or not has_errors:
    labels.append("Espacio de Reserva")
    values.append(max(0, remaining))

# Renderizando el gráfico Dónut
df = pd.DataFrame({"Categorías": labels, "Subredes": values})
fig = px.pie(
    df,
    values="Subredes",
    names="Categorías",
    title="Distribución del Pastel VPC en AWS",
    hole=0.35,
)

fig.update_traces(textposition="inside", textinfo="percent+label")
st.plotly_chart(fig, use_container_width=True)
