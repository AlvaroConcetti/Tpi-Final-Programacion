<%@ Page Title="" Language="C#" MasterPageFile="~/Master.Master" AutoEventWireup="true" CodeBehind="AgregarArticulo.aspx.cs" Inherits="CatalogoWEB.AgregarArticulo" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <asp:ScriptManager runat="server" ID="ScriptManager1" />

    <div class="page-header">
        <div>
            <h1 class="page-title">Artículo</h1>
            <p class="page-subtitle">Completá los datos del artículo</p>
        </div>
    </div>

    <div class="row g-5" style="max-width: 900px;">

        <!-- Columna izquierda: datos -->
        <div class="col-md-6">

            <div class="mb-3">
                <label class="form-label">Id</label>
                <asp:TextBox ID="txtBoxId" runat="server" CssClass="form-control" placeholder="Identificador" />
            </div>

            <div class="mb-3">
                <label class="form-label">Precio</label>
                <asp:TextBox ID="txtBoxPrecio" runat="server" CssClass="form-control" placeholder="0.00" />
                <asp:RequiredFieldValidator ErrorMessage="El precio es obligatorio."
                    ControlToValidate="txtBoxPrecio" runat="server" CssClass="validation-error" Display="Dynamic" />
                <asp:RegularExpressionValidator ErrorMessage="Formato inválido. Use solo coma para los decimales (ej: 120,50)" ControlToValidate="txtBoxPrecio" runat="server" ValidationExpression="^\d+(,\d{1,2})?$" CssClass="validation-error" Display="Dynamic" />
            </div>

            <div class="mb-3">
                <label class="form-label">Stock</label>
                <asp:TextBox ID="txtBoxStock" runat="server" CssClass="form-control" placeholder="0" />
                <asp:RequiredFieldValidator ErrorMessage="El stock es obligatorio."
                    ControlToValidate="txtBoxStock" runat="server" CssClass="validation-error" Display="Dynamic" />
                <asp:RegularExpressionValidator ErrorMessage="El stock debe ser un número entero."
                    ControlToValidate="txtBoxStock" runat="server" ValidationExpression="^\d+$" CssClass="validation-error" Display="Dynamic" />
            </div>

            <div class="mb-3">
                <label class="form-label">Nombre</label>
                <asp:TextBox ID="txtBoxNombre" runat="server" CssClass="form-control" placeholder="Nombre del artículo" MaxLength="50" />
                <asp:RequiredFieldValidator ErrorMessage="El nombre es obligatorio."
                    ControlToValidate="txtBoxNombre" runat="server" CssClass="validation-error" />
            </div>

            <div class="mb-3">
                <label class="form-label">Descripción</label>
                <asp:TextBox ID="txtBoxDescripcion" runat="server" CssClass="form-control"
                    placeholder="Descripción del artículo" TextMode="MultiLine" Rows="3" MaxLength="150" />
            </div>

            <div class="mb-3">
                <label class="form-label">Marca</label>
                <asp:TextBox ID="txtBoxMarca" CssClass="form-control" placeholder="Ejemplo: Apple" runat="server" />
            </div>

            <div class="mb-3">
                <label class="form-label">Categoria</label>
                <asp:TextBox ID="txtBoxCategoria" CssClass="form-select" placeholder="Ejemplo: Telefonos" runat="server" />
            </div>

            <div class="d-flex gap-2 flex-wrap">
                <asp:Button ID="btnAceptar" OnClick="btnAceptar_Click" runat="server"
                    Text="Guardar" CssClass="btn-primary" />
                <asp:Button ID="btnCancelar" OnClick="btnCancelar_Click" runat="server"
                    Text="Cancelar" CssClass="btn-secondary" CausesValidation="false" />

            </div>

        </div>

        <!-- Columna derecha: código + imagen -->
        <div class="col-md-6">

            <div class="mb-3">
                <label class="form-label">Código</label>
                <asp:TextBox ID="txtBoxCodigo" runat="server" CssClass="form-control" placeholder="Código del artículo" />
            </div>

            <asp:UpdatePanel runat="server" ID="UpdatePanel">
                <ContentTemplate>
                    <div class="mb-3">
                        <label class="form-label">Imagen del artículo</label>
                        <input type="file" id="txtImagen" runat="server" class="form-control"
                            onchange="mostrarPreview(this)" style="font-size: 13px;" />
                    </div>
                    <div style="border-radius: var(--radius-md); overflow: hidden; border: 1px solid var(--border); background: var(--surface-raised);">
                        <asp:Image ID="imgArticulo" ImageUrl="https://developers.elementor.com/docs/assets/img/elementor-placeholder-image.png" runat="server"
                            CssClass="img-fluid"
                            ClientIDMode="Static"
                            Style="width: 100%; aspect-ratio: 1; object-fit: cover; display: block;" />
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>

        </div>
    </div>

    <!-- Esto lo hizo claude code ↓ -->
    <script type="text/javascript">
        function mostrarPreview(input) {
            if (input.files && input.files[0]) {
                var reader = new FileReader();
                reader.onload = function (e) {
                    document.getElementById('imgArticulo').src = e.target.result;
                };
                reader.readAsDataURL(input.files[0]);
            }
        }
    </script>

</asp:Content>
