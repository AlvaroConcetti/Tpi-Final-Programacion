<%@ Page Title="" Language="C#" MasterPageFile="~/Master.Master" AutoEventWireup="true" CodeBehind="ImportarArticulos.aspx.cs" Inherits="CatalogoWEB.ImportarArticulos" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <div class="page-header">
        <div>
            <h1 class="page-title">Importar artículos</h1>
            <p class="page-subtitle">Cargá varios artículos a la vez desde un archivo CSV</p>
        </div>
        <asp:Button ID="btnVolverAdmin" Text="← Volver a Administración" runat="server"
            OnClick="btnVolverAdmin_Click" CssClass="btn-ghost" CausesValidation="false" />
    </div>

    <div class="row g-4">
        <!-- Subida del archivo -->
        <div class="col-lg-5">
            <div class="panel" style="padding: 1.25rem;">
                <div class="mb-3">
                    <label class="form-label">Archivo CSV</label>
                    <asp:FileUpload ID="fuArchivoCsv" runat="server" CssClass="form-control" accept=".csv" />
                </div>

                <asp:Button ID="btnImportar" Text="Importar" runat="server"
                    OnClick="btnImportar_Click" CssClass="btn-primary" />

                <asp:Label ID="lblMensaje" runat="server" CssClass="validation-error d-block mt-3" />
            </div>
        </div>

        <!-- Explicacion del formato -->
        <div class="col-lg-7">
            <div class="panel" style="padding: 1.25rem;">
                <p class="form-label">Formato del archivo</p>
                <p style="font-size: 14px; color: var(--text-secondary);">
                    La primera fila tiene que ser el encabezado, y después una fila por artículo,
                    con las columnas separadas por punto y coma (<b>;</b>) en este orden:
                </p>
                <pre style="font-size: 13px; background: var(--surface-raised); padding: 0.75rem; border-radius: var(--radius-md); white-space: pre-wrap;">Codigo;Nombre;Descripcion;Marca;Categoria;Precio;Stock
TVLG55;Televisor LG;Smart TV 55 pulgadas 4K;LG;Televisores;850000,50;10</pre>
                <ul style="font-size: 14px; color: var(--text-secondary); margin-bottom: 0.75rem;">
                    <li>El precio va con coma para los decimales y sin puntos de miles.</li>
                    <li>Si la marca o la categoría no existen, se crean solas.</li>
                    <li>No se cargan los códigos que ya existen en el catálogo.</li>
                    <li>La imagen se agrega después, editando el artículo.</li>
                    <li>Desde Excel: <i>Guardar como → CSV (delimitado por comas)</i>.</li>
                </ul>
                <a href="Content/plantilla_articulos.csv" download class="btn-outline" style="text-decoration: none; display: inline-block;">
                    <i class="bi bi-download me-1"></i>Descargar plantilla
                </a>
            </div>
        </div>
    </div>

    <!-- Resultado de la importacion -->
    <asp:Panel ID="pnlResultado" runat="server" Visible="false" CssClass="panel mt-4" style="padding: 1.25rem;">
        <p class="form-label mb-2">Resultado</p>
        <p style="margin: 0 0 0.75rem;">
            <span class="tag">✔ <asp:Label ID="lblAgregados" runat="server" /> agregados</span>
            <span class="tag">✖ <asp:Label ID="lblConError" runat="server" /> con error</span>
        </p>

        <asp:GridView ID="dgvErrores" runat="server" CssClass="table" AutoGenerateColumns="false">
            <Columns>
                <asp:BoundField HeaderText="Fila" DataField="Fila" />
                <asp:BoundField HeaderText="Código" DataField="Codigo" />
                <asp:BoundField HeaderText="Problema" DataField="Motivo" />
            </Columns>
        </asp:GridView>
    </asp:Panel>

</asp:Content>
