<%@ Page Title="" Language="C#" MasterPageFile="~/Master.Master" AutoEventWireup="true" CodeBehind="AgregarArticulo.aspx.cs" Inherits="CatalogoWEB.AgregarArticulo" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <div class="back-row">
        <asp:Button ID="btnVolver" Text="← Volver a artículos" runat="server"
            OnClick="btnCancelar_Click" CssClass="btn-ghost" CausesValidation="false" />
    </div>

    <div class="page-header">
        <div>
            <h1 class="page-title"><%= EsEdicion ? "Editar artículo" : "Nuevo artículo" %></h1>
            <p class="page-subtitle"><%= EsEdicion ? "Modificá los datos y guardá los cambios." : "Completá los datos para sumarlo al catálogo." %></p>
        </div>
    </div>

    <!-- El Id no se edita: se toma de la URL. Queda oculto para no confundir. -->
    <asp:TextBox ID="txtBoxId" runat="server" Visible="false" />

    <div class="article-form">

        <!-- Columna principal: datos agrupados en tarjetas -->
        <div class="article-form-main">

            <section class="form-card">
                <h2 class="form-card-title">Información</h2>

                <div class="form-field">
                    <label class="form-label" for="<%= txtBoxNombre.ClientID %>">Nombre</label>
                    <asp:TextBox ID="txtBoxNombre" runat="server" CssClass="form-control" placeholder="Ej: iPhone 16 Pro Max" MaxLength="50" />
                    <asp:RequiredFieldValidator ErrorMessage="El nombre es obligatorio."
                        ControlToValidate="txtBoxNombre" runat="server" CssClass="validation-error" Display="Dynamic" />
                </div>

                <div class="form-field">
                    <label class="form-label" for="<%= txtBoxCodigo.ClientID %>">Código</label>
                    <asp:TextBox ID="txtBoxCodigo" runat="server" CssClass="form-control" placeholder="Ej: IP16PM" MaxLength="50" />
                    <p class="form-hint">Identifica al artículo y se usa para el nombre del archivo de la imagen.</p>
                    <asp:RequiredFieldValidator ErrorMessage="El código es obligatorio."
                        ControlToValidate="txtBoxCodigo" runat="server" CssClass="validation-error" Display="Dynamic" />
                </div>

                <div class="form-field">
                    <div class="form-label-row">
                        <label class="form-label" for="<%= txtBoxDescripcion.ClientID %>">Descripción</label>
                        <span class="form-counter" id="contadorDescripcion">0/150</span>
                    </div>
                    <asp:TextBox ID="txtBoxDescripcion" runat="server" CssClass="form-control"
                        placeholder="Contá en una o dos líneas qué es y qué lo destaca" TextMode="MultiLine" Rows="3" MaxLength="150" />
                </div>
            </section>

            <section class="form-card">
                <h2 class="form-card-title">Precio y stock</h2>

                <div class="form-grid-2">
                    <div class="form-field">
                        <label class="form-label" for="<%= txtBoxPrecio.ClientID %>">Precio</label>
                        <div class="input-prefix">
                            <span>$</span>
                            <asp:TextBox ID="txtBoxPrecio" runat="server" CssClass="form-control" placeholder="0,00" inputmode="decimal" />
                        </div>
                        <asp:RequiredFieldValidator ErrorMessage="El precio es obligatorio."
                            ControlToValidate="txtBoxPrecio" runat="server" CssClass="validation-error" Display="Dynamic" />
                        <asp:RegularExpressionValidator ErrorMessage="Usá solo números y coma para los decimales (ej: 1500,50)."
                            ControlToValidate="txtBoxPrecio" runat="server" ValidationExpression="^\d+(,\d{1,2})?$" CssClass="validation-error" Display="Dynamic" />
                    </div>

                    <div class="form-field">
                        <label class="form-label" for="<%= txtBoxStock.ClientID %>">Stock</label>
                        <asp:TextBox ID="txtBoxStock" runat="server" CssClass="form-control" placeholder="0" inputmode="numeric" />
                        <asp:RequiredFieldValidator ErrorMessage="El stock es obligatorio."
                            ControlToValidate="txtBoxStock" runat="server" CssClass="validation-error" Display="Dynamic" />
                        <asp:RegularExpressionValidator ErrorMessage="El stock debe ser un número entero."
                            ControlToValidate="txtBoxStock" runat="server" ValidationExpression="^\d+$" CssClass="validation-error" Display="Dynamic" />
                    </div>
                </div>
            </section>

            <section class="form-card">
                <h2 class="form-card-title">Clasificación</h2>

                <!-- Desplegables con las marcas/categorias existentes: evita duplicados por mayusculas o espacios -->
                <div class="form-grid-2">
                    <div class="form-field">
                        <label class="form-label" for="<%= ddlMarca.ClientID %>">Marca</label>
                        <asp:DropDownList ID="ddlMarca" runat="server" CssClass="form-select" />
                        <asp:RequiredFieldValidator ErrorMessage="Elegí una marca."
                            ControlToValidate="ddlMarca" InitialValue="" runat="server" CssClass="validation-error" Display="Dynamic" />
                    </div>

                    <div class="form-field">
                        <label class="form-label" for="<%= ddlCategoria.ClientID %>">Categoría</label>
                        <asp:DropDownList ID="ddlCategoria" runat="server" CssClass="form-select" />
                        <asp:RequiredFieldValidator ErrorMessage="Elegí una categoría."
                            ControlToValidate="ddlCategoria" InitialValue="" runat="server" CssClass="validation-error" Display="Dynamic" />
                    </div>
                </div>
                <p class="form-hint">¿No está la que necesitás? Agregala en <a href="CategoriasMarcas.aspx">Categorías y marcas</a>.</p>
            </section>
        </div>

        <!-- Columna lateral: imagen + vista previa en vivo de la card del catalogo -->
        <aside class="article-form-side">
            <section class="form-card">
                <h2 class="form-card-title">Vista previa</h2>
                <p class="form-hint form-hint--top">Así se va a ver en el catálogo.</p>

                <div class="preview-card">
                    <div class="product-media">
                        <asp:Image ID="imgArticulo" runat="server" ClientIDMode="Static" AlternateText="Imagen del artículo" />
                        <span class="preview-empty" id="previewSinImagen">Sin imagen</span>
                    </div>
                    <div class="product-info">
                        <p class="product-status" id="previewEstado"></p>
                        <p class="product-name" id="previewNombre">Nombre del artículo</p>
                        <p class="product-meta" id="previewMeta">Categoría · Marca</p>
                        <p class="product-price" id="previewPrecio">$0,00</p>
                    </div>
                </div>

                <label class="btn-outline btn-block upload-btn" for="<%= txtImagen.ClientID %>">
                    <i class="bi bi-image"></i>
                    <span id="lblImagen"><%= EsEdicion ? "Cambiar imagen" : "Elegir imagen" %></span>
                </label>
                <input type="file" id="txtImagen" runat="server" class="visually-hidden"
                    accept="image/*" onchange="mostrarPreview(this)" />
                <p class="form-hint" id="nombreArchivo">JPG o PNG. Se recomienda fondo blanco.</p>
            </section>
        </aside>
    </div>

    <!-- Barra de acciones fija abajo -->
    <div class="form-actions-bar">
        <asp:Button ID="btnCancelar" OnClick="btnCancelar_Click" runat="server"
            Text="Cancelar" CssClass="btn-outline" CausesValidation="false" />
        <asp:Button ID="btnAceptar" OnClick="btnAceptar_Click" runat="server"
            Text="Guardar" CssClass="btn-primary" />
    </div>

    <script type="text/javascript">
        // Vista previa en vivo: replica la card del catalogo con lo que se va escribiendo.
        (function () {
            function $(id) { return document.getElementById(id); }
            var nombre = $('<%= txtBoxNombre.ClientID %>');
            var descripcion = $('<%= txtBoxDescripcion.ClientID %>');
            var precio = $('<%= txtBoxPrecio.ClientID %>');
            var stock = $('<%= txtBoxStock.ClientID %>');
            var marca = $('<%= ddlMarca.ClientID %>');
            var categoria = $('<%= ddlCategoria.ClientID %>');
            var img = $('imgArticulo');

            function textoSeleccionado(ddl) {
                return ddl.value ? ddl.options[ddl.selectedIndex].text : '';
            }

            function actualizar() {
                $('previewNombre').textContent = nombre.value.trim() || 'Nombre del artículo';
                $('previewMeta').textContent = (textoSeleccionado(categoria) || 'Categoría') + ' · ' + (textoSeleccionado(marca) || 'Marca');

                var valor = parseFloat((precio.value || '0').replace(',', '.'));
                $('previewPrecio').textContent = '$' + (isNaN(valor) ? 0 : valor).toLocaleString('es-AR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });

                // Mismo criterio que el catalogo: 0 = Agotado, 1 a 5 = Ultimas unidades
                var s = parseInt(stock.value, 10);
                var estado = $('previewEstado');
                estado.className = 'product-status' + (s === 0 ? ' product-status--agotado' : '');
                estado.textContent = isNaN(s) ? '' : (s === 0 ? 'Agotado' : (s <= 5 ? 'Últimas unidades' : ''));

                $('contadorDescripcion').textContent = descripcion.value.length + '/150';
            }

            [nombre, descripcion, precio, stock].forEach(function (el) { el.addEventListener('input', actualizar); });
            [marca, categoria].forEach(function (el) { el.addEventListener('change', actualizar); });

            function estadoImagen() {
                var tiene = img.getAttribute('src');
                img.style.display = tiene ? '' : 'none';
                $('previewSinImagen').style.display = tiene ? 'none' : '';
            }
            img.addEventListener('error', function () { img.removeAttribute('src'); estadoImagen(); });

            window.mostrarPreview = function (input) {
                if (!input.files || !input.files[0]) return;
                var archivo = input.files[0];
                var reader = new FileReader();
                reader.onload = function (e) { img.src = e.target.result; estadoImagen(); };
                reader.readAsDataURL(archivo);
                $('nombreArchivo').textContent = archivo.name;
                $('lblImagen').textContent = 'Cambiar imagen';
            };

            estadoImagen();
            actualizar();
        })();
    </script>

</asp:Content>
