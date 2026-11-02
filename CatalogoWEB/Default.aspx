<%@ Page Title="" Language="C#" MasterPageFile="~/Master.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="CatalogoWEB.Default" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <asp:ScriptManager runat="server" />

    <div class="page-header">
        <div>
            <h1 class="page-title">Catálogo</h1>
            <p class="page-subtitle">Explorá todos los artículos disponibles</p>
        </div>
        <!-- Esto lo hizo claude code ↓ -->
        <!-- Solo visible en mobile (ver media query), abre/cierra el sidebar de filtros -->
        <button type="button" class="btn-outline filter-mobile-toggle" onclick="toggleFilterSidebarMobile()">
            <i class="bi bi-funnel me-1"></i>Filtros
        </button>
    </div>

    <!-- Esto lo hizo claude code ↓ -->
    <!-- Sidebar de filtros: categorias y marcas derivadas de los articulos ya cargados -->
    <div class="catalog-layout">
        <aside class="filter-sidebar" id="filterSidebar">
            <div class="filter-sidebar-header">
                <h2>Filtros</h2>
                <button type="button" class="btn-ghost" style="padding: 0.2rem 0.5rem; font-size: 12.5px;" onclick="limpiarFiltros()">Limpiar</button>
            </div>

            <asp:Repeater runat="server" ID="repFiltros">
                <ItemTemplate>
                    <div class="filter-group">
                        <div class="filter-category-row">
                            <label class="filter-checkbox-label">
                                <input type="checkbox" class="filtro-categoria" value='<%#Eval("Nombre")%>' onchange="aplicarFiltros()" />
                                <span><%#Eval("Nombre")%></span>
                            </label>
                            <asp:PlaceHolder runat="server" Visible='<%# ((FiltroCategoria)Container.DataItem).Marcas.Count > 0 %>'>
                                <button type="button" class="filter-toggle" onclick="toggleCategoriaExpand(this)" aria-label="Desplegar marcas">
                                    <i class="bi bi-chevron-down"></i>
                                </button>
                            </asp:PlaceHolder>
                        </div>

                        <div class="filter-subgroup">
                            <asp:Repeater runat="server" ID="repMarcasFiltro" DataSource='<%#Eval("Marcas")%>'>
                                <ItemTemplate>
                                    <label class="filter-checkbox-label filter-checkbox-label--nested">
                                        <input type="checkbox" class="filtro-marca"
                                            data-categoria='<%#Eval("Categoria")%>' data-marca='<%#Eval("Nombre")%>'
                                            onchange="aplicarFiltros()" />
                                        <span><%#Eval("Nombre")%></span>
                                    </label>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </aside>

        <div class="catalog-main">

            <div class="search-bar">
                <asp:TextBox ID="txtBoxFiltro" runat="server" CssClass="form-control" placeholder="Buscar artículos..." />
                <asp:Button ID="btnBuscarFiltro" runat="server" Text="Buscar" OnClick="btnBuscarFiltro_Click" CssClass="btn-primary" />
                <asp:Button ID="btnBorrarFiltro" runat="server" Text="Limpiar" OnClick="btnBorrarFiltro_Click" CssClass="btn-outline" />
            </div>

            <!-- Esto lo hizo claude code -->
            <!-- Notificacion flotante que se muestra al agregar un articulo al carrito -->
            <div id="toastCarrito" class="toast-notification">
                <i class="bi bi-check-circle-fill me-1"></i>
                <span class="toast-text"></span>
            </div>
            <script type="text/javascript">
                function mostrarToast(mensaje) {
                    var toast = document.getElementById('toastCarrito');
                    if (!toast) return;
                    toast.querySelector('.toast-text').textContent = mensaje;
                    toast.classList.add('show');
                    clearTimeout(toast._timer);
                    toast._timer = setTimeout(function () {
                        toast.classList.remove('show');
                    }, 2200);
                }
            </script>

            <asp:UpdatePanel runat="server">
                <ContentTemplate>
                    <div class="row row-cols-1 row-cols-sm-2 row-cols-lg-3 row-cols-xl-4 g-3">

                        <asp:Repeater runat="server" ID="repRepetidor">
                            <ItemTemplate>
                                <div class="col">
                                    <!-- Esto lo hizo claude code ↓ -->
                                    <!-- Toda la card es clickeable (salvo .no-card-click) y dispara el postback de btnDetalle -->
                                    <!-- data-categoria/data-marca: los usa el filtro del sidebar (JS) -->
                                    <div class="catalog-card h-100 catalog-card--shop"
                                        data-categoria='<%#Eval("Categoria")%>' data-marca='<%#Eval("Marca")%>'
                                        onclick="clickCard(event, this)">

                                        <img src="<%#Eval("UrlImagen")%>" alt="<%#Eval("Nombre")%>" onerror="this.onerror=null;this.src='data:image/svg+xml,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 width=%22400%22 height=%22300%22%3E%3Crect width=%22400%22 height=%22300%22 fill=%22%231a1f2e%22/%3E%3Ctext x=%2250%25%22 y=%2250%25%22 dominant-baseline=%22middle%22 text-anchor=%22middle%22 font-family=%22sans-serif%22 font-size=%2214%22 fill=%22%23404e68%22%3ESin imagen%3C/text%3E%3C/svg%3E'" />

                                        <!-- Esto lo hizo claude code ↓ -->
                                        <!-- Boton favorito sobre la foto -->
                                        <asp:LinkButton ID="btnFavorito" runat="server" OnClick="btnFavorito_Click"
                                            CommandArgument='<%# Eval("Id") %>'
                                            CommandName="AddFavorito"
                                            CssClass='<%# (EsFavorito((int)Eval("Id")) ? "fav-btn fav-btn--activo" : "fav-btn") + " no-card-click" %>'>
                                            <i class='<%# EsFavorito((int)Eval("Id")) ? "bi bi-heart-fill" : "bi bi-heart" %>'></i>
                                        </asp:LinkButton>

                                        <div class="catalog-card-body">
                                            <p class="catalog-card-title"><%#Eval("Nombre")%></p>
                                            <p style="font-size: 14px; font-weight: 600; color: var(--price-color); margin: 0 0 0.2rem;">$<%#Eval("Precio", "{0:N2}")%></p>
                                            <p class="stock-info"><%# (int)Eval("Stock") > 0 ? "Stock: " + Eval("Stock") : "Sin stock" %></p>

                                            <!-- Hace el postback real de "Ver detalle" cuando se clickea la card -->
                                            <asp:Button ID="btnDetalle" runat="server"
                                                OnClick="btnDetalle_Click"
                                                CommandArgument='<%#Eval("Id")%>'
                                                CommandName="ArticuloId"
                                                CssClass="card-click-target"
                                                Style="display: none;" />

                                            <!-- Si hay stock muestra el text -->
                                            <asp:Button ID="btnAgregarAlCarrito" runat="server"
                                                OnClick="btnAgregarAlCarrito_Click"
                                                CommandArgument='<%#Eval("Id")%>'
                                                CommandName="ArticuloId"
                                                CssClass="btn-info-soft no-card-click"
                                                Text="Agregar al carrito"
                                                Visible='<%# CantidadEnCarrito((int)Eval("Id")) == 0 && (int)Eval("Stock") > 0 %>'
                                                Style="width: 100%; margin-top: 0.5rem;" />

                                            <!-- Esto lo hizo claude code ↓ -->
                                            <!-- Cuando hay minimo 1 articulo en el carrito  -->
                                            <asp:Panel ID="pnlStepper" runat="server" CssClass="qty-stepper no-card-click"
                                                Visible='<%# CantidadEnCarrito((int)Eval("Id")) > 0 %>'>
                                                <asp:LinkButton ID="btnMenos" runat="server" CssClass="qty-btn"
                                                    OnClick="btnMenosCantidad_Click"
                                                    CommandArgument='<%#Eval("Id")%>'>
                                                    <i class="bi bi-dash"></i>
                                                </asp:LinkButton>
                                                <span class="qty-value"><%# CantidadEnCarrito((int)Eval("Id")) %> en tu carrito</span>
                                                <asp:LinkButton ID="btnMas" runat="server"
                                                    CssClass='<%# CantidadEnCarrito((int)Eval("Id")) < (int)Eval("Stock") ? "qty-btn" : "qty-btn qty-btn--disabled" %>'
                                                    OnClick="btnMasCantidad_Click"
                                                    CommandArgument='<%#Eval("Id")%>'
                                                    Enabled='<%# CantidadEnCarrito((int)Eval("Id")) < (int)Eval("Stock") %>'>
                                                    <i class="bi bi-plus"></i>
                                                </asp:LinkButton>
                                            </asp:Panel>

                                            <!-- Si no hay stock muestra el text y bloquea el boton -->
                                            <asp:Button ID="btnSinStock" runat="server"
                                                CssClass="btn-danger-soft no-card-click"
                                                Text="Stock agotado"
                                                Enabled="false"
                                                Visible='<%# CantidadEnCarrito((int)Eval("Id")) == 0 && (int)Eval("Stock") == 0 %>'
                                                Style="width: 100%; margin-top: 0.5rem;" />
                                        </div>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>

        </div>
    </div>

    <!-- Esto lo hizo claude code -->
    <script type="text/javascript">
        // Filtro del sidebar: OR entre categorias tildadas, OR entre marcas tildadas
        // dentro de una misma categoria, AND entre categoria y sus marcas tildadas.
        function aplicarFiltros() {
            var categoriasChecked = [];
            document.querySelectorAll('.filtro-categoria:checked').forEach(function (cb) {
                categoriasChecked.push(cb.value);
            });

            var marcasChecked = [];
            document.querySelectorAll('.filtro-marca:checked').forEach(function (cb) {
                marcasChecked.push({ categoria: cb.getAttribute('data-categoria'), marca: cb.getAttribute('data-marca') });
            });

            document.querySelectorAll('.catalog-card[data-categoria]').forEach(function (card) {
                var col = card.closest('.col');
                if (!col) return;

                var visible = true;
                if (categoriasChecked.length > 0) {
                    var cat = card.getAttribute('data-categoria');
                    var marca = card.getAttribute('data-marca');

                    if (categoriasChecked.indexOf(cat) === -1) {
                        visible = false;
                    } else {
                        var marcasDeEstaCategoria = marcasChecked.filter(function (m) { return m.categoria === cat; });
                        if (marcasDeEstaCategoria.length > 0) {
                            visible = marcasDeEstaCategoria.some(function (m) { return m.marca === marca; });
                        }
                    }
                }

                col.style.display = visible ? '' : 'none';
            });
        }

        function limpiarFiltros() {
            document.querySelectorAll('.filtro-categoria, .filtro-marca').forEach(function (cb) {
                cb.checked = false;
            });
            aplicarFiltros();
        }

        function toggleCategoriaExpand(boton) {
            var grupo = boton.closest('.filter-group');
            if (grupo) grupo.classList.toggle('open');
        }

        function toggleFilterSidebarMobile() {
            var sidebar = document.getElementById('filterSidebar');
            if (sidebar) sidebar.classList.toggle('mobile-open');
        }

        // El grid de articulos se re-renderiza en cada postback parcial (buscar, agregar al
        // carrito, etc.), lo que borra las cards viejas; hay que volver a aplicar el filtro
        // tildado sobre las cards nuevas para que no "se resetee" visualmente.
        // Ademas se guarda/restaura el scroll en el mismo ciclo: el reemplazo del DOM
        // hacia saltar la pagina arriba y MaintainScrollPositionOnPostback la devolvia
        // tarde (efecto "sube y baja"); restaurando aca, antes del repaint, no se nota.
        if (window.Sys && Sys.WebForms && Sys.WebForms.PageRequestManager) {
            var prm = Sys.WebForms.PageRequestManager.getInstance();
            var scrollGuardado = 0;
            prm.add_beginRequest(function () {
                scrollGuardado = window.pageYOffset;
            });
            prm.add_endRequest(function () {
                aplicarFiltros();
                // Bootstrap pone scroll-behavior:smooth en :root, lo que convierte este
                // scrollTo en una animacion visible que ademas se cancela si el usuario
                // mueve la rueda en ese momento (por eso "a veces andaba y a veces no").
                // Se anula temporalmente para que la restauracion sea instantanea.
                var raiz = document.documentElement;
                var comportamientoPrevio = raiz.style.scrollBehavior;
                raiz.style.scrollBehavior = 'auto';
                window.scrollTo(0, scrollGuardado);
                raiz.style.scrollBehavior = comportamientoPrevio;
            });
        }
    </script>

</asp:Content>
