<%@ Page Title="" Language="C#" MasterPageFile="~/Master.Master" AutoEventWireup="true" CodeBehind="ImportarArticulos.aspx.cs" Inherits="CatalogoWEB.ImportarArticulos" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <div class="back-row">
        <asp:Button ID="btnVolverAdmin" Text="← Volver a artículos" runat="server"
            OnClick="btnVolverAdmin_Click" CssClass="btn-ghost" CausesValidation="false" />
    </div>

    <div class="page-header">
        <div>
            <h1 class="page-title">Importar artículos</h1>
            <p class="page-subtitle">Cargá varios artículos a la vez desde un archivo CSV</p>
        </div>
    </div>

    <div class="import-grid">
        <!-- Subida del archivo -->
        <section class="form-card">
            <h2 class="form-card-title">Archivo CSV</h2>
            <div class="form-field">
                <asp:FileUpload ID="fuArchivoCsv" runat="server" CssClass="form-control" accept=".csv" />
                <p class="form-hint">Separado por punto y coma. Podés partir de la plantilla.</p>
            </div>

            <div class="form-card-actions">
                <asp:Label ID="lblMensaje" runat="server" CssClass="validation-error form-message" />
                <asp:Button ID="btnImportar" Text="Importar" runat="server"
                    OnClick="btnImportar_Click" CssClass="btn-primary" />
            </div>
        </section>

        <!-- Explicacion del formato -->
        <section class="form-card">
            <h2 class="form-card-title">Formato del archivo</h2>
            <p class="import-text">
                La primera fila es el encabezado, y después va una fila por artículo,
                con las columnas separadas por punto y coma (<b>;</b>) en este orden:
            </p>
            <pre class="import-code">Codigo;Nombre;Descripcion;Marca;Categoria;Precio;Stock
TVLG55;Televisor LG;Smart TV 55 pulgadas 4K;LG;Televisores;850000,50;10</pre>
            <ul class="import-list">
                <li>El precio va con coma para los decimales y sin puntos de miles.</li>
                <li>Si la marca o la categoría no existen, se crean solas.</li>
                <li>No se cargan los códigos que ya existen en el catálogo.</li>
                <li>La imagen se agrega después, editando el artículo.</li>
                <li>Desde Excel: <i>Guardar como → CSV (delimitado por comas)</i>.</li>
            </ul>
            <a href="Content/plantilla_articulos.csv" download class="btn-outline">
                <i class="bi bi-download"></i>Descargar plantilla
            </a>
        </section>
    </div>

    <!-- Resultado de la importacion -->
    <asp:Panel ID="pnlResultado" runat="server" Visible="false" CssClass="import-result">
        <h2 class="form-card-title">Resultado</h2>
        <div class="import-summary">
            <span class="stock-badge import-ok"><asp:Label ID="lblAgregados" runat="server" /> agregados</span>
            <span class="stock-badge stock-badge--cero"><asp:Label ID="lblConError" runat="server" /> con error</span>
        </div>

        <div class="panel">
            <asp:GridView ID="dgvErrores" runat="server" CssClass="table" AutoGenerateColumns="false">
                <Columns>
                    <asp:BoundField HeaderText="Fila" DataField="Fila" />
                    <asp:BoundField HeaderText="Código" DataField="Codigo" />
                    <asp:BoundField HeaderText="Problema" DataField="Motivo" />
                </Columns>
            </asp:GridView>
        </div>
    </asp:Panel>

</asp:Content>
