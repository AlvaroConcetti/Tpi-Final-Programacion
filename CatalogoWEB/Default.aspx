<%@ Page Title="" Language="C#" MasterPageFile="~/Master.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="CatalogoWEB.Default" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <asp:ScriptManager runat="server" />

    <!-- Cartel de bienvenida: titulo grande centrado + vitrina con los ultimos articulos agregados.
         Se oculta mientras hay una busqueda aplicada, para que los resultados queden arriba. -->
    <asp:Panel ID="pnlBienvenida" runat="server" CssClass="hero">
        <p class="hero-kicker">Bienvenido</p>
        <h1 class="hero-title">Elegí. Armá tu carrito. Pedilo por WhatsApp.</h1>
        <p class="hero-sub">Explorá el catálogo, guardá tus favoritos y enviá tu pedido en un par de clics.</p>
        <div class="hero-ctas">
            <a href="#catalogo" class="btn-primary">Ver catálogo</a>
            <%if (Consultas.Seguridad.SesionActiva(Session["Usuario"]))
                {%>
            <a href="Carrito.aspx" class="btn-outline">Ir a mi carrito</a>
            <%}
            else
            {%>
            <a href="Registrarse.aspx" class="btn-outline">Crear cuenta</a>
            <%}%>
        </div>

        <!-- Vitrina: los 3 articulos con stock agregados mas recientemente (ver CargarVitrina en el code-behind) -->
        <asp:Panel ID="pnlVitrina" runat="server" CssClass="hero-stage">
            <asp:Repeater runat="server" ID="repVitrina">
                <ItemTemplate>
                    <div class="hero-pick" onclick="clickCard(event, this)">
                        <div class="hero-pick-media">
                            <img src="<%#Eval("UrlImagen")%>" alt="<%#Eval("Nombre")%>" onerror="this.onerror=null;this.style.visibility='hidden'" />
                        </div>
                        <div class="hero-callout">
                            <div class="hero-callout-text">
                                <span class="hero-callout-label">Recién agregado</span>
                                <span class="hero-callout-name"><%#Eval("Nombre")%></span>
                                <span class="hero-callout-price">$<%#Eval("Precio", "{0:N2}")%></span>
                            </div>
                            <!-- Mismo postback de "Ver detalle" que las cards de la grilla -->
                            <asp:Button runat="server" ID="btnVitrinaDetalle" Text="Ver"
                                OnClick="btnDetalle_Click"
                                CommandArgument='<%#Eval("Id")%>'
                                CommandName="ArticuloId"
                                CssClass="btn-primary hero-callout-btn card-click-target no-card-click" />
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </asp:Panel>
    </asp:Panel>

    <!-- Encabezado: titulo con cantidad de articulos visibles + buscador + mostrar/ocultar filtros -->
    <div class="plp-header" id="catalogo">
        <h2 class="page-title">Catálogo <span class="plp-count" id="plpCount"></span></h2>

        <div class="plp-tools">
            <!-- DefaultButton: Enter en el buscador dispara "Buscar" (y no el boton de sesion del navbar) -->
            <asp:Panel runat="server" CssClass="search-bar" DefaultButton="btnBuscarFiltro">
                <div class="search-pill">
                    <i class="bi bi-search"></i>
                    <asp:TextBox ID="txtBoxFiltro" runat="server" CssClass="form-control" placeholder="Buscar artículos" />
                    <asp:Button ID="btnBuscarFiltro" runat="server" Text="Buscar" OnClick="btnBuscarFiltro_Click" CssClass="btn-primary" />
                </div>
                <asp:Button ID="btnBorrarFiltro" runat="server" Text="Limpiar" OnClick="btnBorrarFiltro_Click" CssClass="btn-ghost" />
            </asp:Panel>

            <!-- En escritorio oculta/muestra el sidebar; en mobile lo despliega arriba de la grilla -->
            <button type="button" class="plp-toggle" onclick="toggleFiltros()">
                <span id="lblToggleFiltros">Ocultar filtros</span>
                <i class="bi bi-sliders2"></i>
            </button>
        </div>
    </div>

    <!-- Sidebar de filtros: categorias y marcas derivadas de los articulos ya cargados -->
    <div class="catalog-layout" id="catalogLayout">
        <aside class="filter-sidebar" id="filterSidebar">
            <div class="filter-sidebar-header">
                <h2>Categorías</h2>
                <button type="button" class="filter-clear" onclick="limpiarFiltros()">Limpiar</button>
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

            <!-- Notificacion flotante que se muestra al agregar un articulo al carrito -->
            <div id="toastCarrito" class="toast-notification">
                <i class="bi bi-check-circle-fill"></i>
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
                    <div class="product-grid">

                        <asp:Repeater runat="server" ID="repRepetidor">
                            <ItemTemplate>
                                <div class="product-item">
                                    <!-- Toda la card es clickeable (salvo .no-card-click) y dispara el postback de btnDetalle -->
                                    <!-- data-categoria/data-marca: los usa el filtro del sidebar (JS) -->
                                    <div class="product-card"
                                        data-categoria='<%#Eval("Categoria")%>' data-marca='<%#Eval("Marca")%>'
                                        onclick="clickCard(event, this)">

                                        <div class="product-media">
                                            <img src="<%#Eval("UrlImagen")%>" alt="<%#Eval("Nombre")%>" loading="lazy" onerror="this.onerror=null;this.src='data:image/svg+xml,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 width=%22400%22 height=%22400%22%3E%3Crect width=%22400%22 height=%22400%22 fill=%22%23f5f5f5%22/%3E%3Ctext x=%2250%25%22 y=%2250%25%22 dominant-baseline=%22middle%22 text-anchor=%22middle%22 font-family=%22sans-serif%22 font-size=%2216%22 fill=%22%239e9ea0%22%3ESin imagen%3C/text%3E%3C/svg%3E'" />

                                            <!-- Boton favorito sobre la foto -->
                                            <asp:LinkButton ID="btnFavorito" runat="server" OnClick="btnFavorito_Click"
                                                CommandArgument='<%# Eval("Id") %>'
                                                CommandName="AddFavorito"
                                                CssClass='<%# (EsFavorito((int)Eval("Id")) ? "fav-btn fav-btn--activo" : "fav-btn") + " no-card-click" %>'
                                                ToolTip='<%# EsFavorito((int)Eval("Id")) ? "Quitar de favoritos" : "Agregar a favoritos" %>'>
                                                <i class='<%# EsFavorito((int)Eval("Id")) ? "bi bi-heart-fill" : "bi bi-heart" %>'></i>
                                            </asp:LinkButton>
                                        </div>

                                        <div class="product-info">
                                            <!-- Etiqueta de stock: mismo umbral que el panel "Stock bajo" del Dashboard (5 o menos) -->
                                            <p class='<%# (int)Eval("Stock") == 0 ? "product-status product-status--agotado" : "product-status" %>'><%# (int)Eval("Stock") == 0 ? "Agotado" : ((int)Eval("Stock") <= 5 ? "Últimas unidades" : "") %></p>
                                            <p class="product-name"><%#Eval("Nombre")%></p>
                                            <p class="product-meta"><%#Eval("Categoria")%> · <%#Eval("Marca")%></p>
                                            <p class="product-meta"><%# (int)Eval("Stock") > 0 ? Eval("Stock") + " en stock" : "Sin stock" %></p>
                                            <p class="product-price">$<%#Eval("Precio", "{0:N2}")%></p>

                                            <!-- Hace el postback real de "Ver detalle" cuando se clickea la card -->
                                            <asp:Button ID="btnDetalle" runat="server"
                                                OnClick="btnDetalle_Click"
                                                CommandArgument='<%#Eval("Id")%>'
                                                CommandName="ArticuloId"
                                                CssClass="card-click-target"
                                                Style="display: none;" />

                                            <div class="product-actions">
                                                <!-- Si hay stock y no esta en el carrito -->
                                                <asp:Button ID="btnAgregarAlCarrito" runat="server"
                                                    OnClick="btnAgregarAlCarrito_Click"
                                                    CommandArgument='<%#Eval("Id")%>'
                                                    CommandName="ArticuloId"
                                                    CssClass="btn-info-soft no-card-click"
                                                    Text="Agregar al carrito"
                                                    Visible='<%# CantidadEnCarrito((int)Eval("Id")) == 0 && (int)Eval("Stock") > 0 %>' />

                                                <!-- Cuando hay minimo 1 unidad en el carrito -->
                                                <asp:Panel ID="pnlStepper" runat="server" CssClass="qty-stepper no-card-click"
                                                    Visible='<%# CantidadEnCarrito((int)Eval("Id")) > 0 %>'>
                                                    <asp:LinkButton ID="btnMenos" runat="server" CssClass="qty-btn"
                                                        OnClick="btnMenosCantidad_Click"
                                                        CommandArgument='<%#Eval("Id")%>' ToolTip="Quitar una unidad">
                                                        <i class="bi bi-dash"></i>
                                                    </asp:LinkButton>
                                                    <span class="qty-value"><%# CantidadEnCarrito((int)Eval("Id")) %> en tu carrito</span>
                                                    <asp:LinkButton ID="btnMas" runat="server"
                                                        CssClass='<%# CantidadEnCarrito((int)Eval("Id")) < (int)Eval("Stock") ? "qty-btn" : "qty-btn qty-btn--disabled" %>'
                                                        OnClick="btnMasCantidad_Click"
                                                        CommandArgument='<%#Eval("Id")%>'
                                                        Enabled='<%# CantidadEnCarrito((int)Eval("Id")) < (int)Eval("Stock") %>'
                                                        ToolTip="Agregar una unidad">
                                                        <i class="bi bi-plus"></i>
                                                    </asp:LinkButton>
                                                </asp:Panel>

                                                <!-- Si no hay stock bloquea el boton -->
                                                <asp:Button ID="btnSinStock" runat="server"
                                                    CssClass="btn-danger-soft no-card-click"
                                                    Text="Stock agotado"
                                                    Enabled="false"
                                                    Visible='<%# CantidadEnCarrito((int)Eval("Id")) == 0 && (int)Eval("Stock") == 0 %>' />
                                            </div>
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

            var visibles = 0;
            document.querySelectorAll('.product-card[data-categoria]').forEach(function (card) {
                var item = card.closest('.product-item');
                if (!item) return;

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

                item.style.display = visible ? '' : 'none';
                if (visible) visibles++;
            });

            // Contador junto al titulo: "Catálogo (12)"
            var contador = document.getElementById('plpCount');
            if (contador) contador.textContent = '(' + visibles + ')';
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

        // Escritorio: oculta/muestra el sidebar y la grilla ocupa todo el ancho.
        // Mobile: el sidebar arranca oculto y se despliega arriba de la grilla.
        function toggleFiltros() {
            var layout = document.getElementById('catalogLayout');
            var sidebar = document.getElementById('filterSidebar');
            var etiqueta = document.getElementById('lblToggleFiltros');
            var abierto;

            if (window.innerWidth <= 991) {
                abierto = sidebar.classList.toggle('mobile-open');
            } else {
                abierto = !layout.classList.toggle('filters-hidden');
            }
            etiqueta.textContent = abierto ? 'Ocultar filtros' : 'Mostrar filtros';
        }

        // La etiqueta del boton arranca segun el estado real (en mobile el sidebar empieza cerrado)
        if (window.innerWidth <= 991) {
            document.getElementById('lblToggleFiltros').textContent = 'Mostrar filtros';
        }

        aplicarFiltros();

        // El grid de articulos se re-renderiza en cada postback parcial (agregar al carrito,
        // favoritos, etc.), lo que borra las cards viejas; hay que volver a aplicar el filtro
        // tildado sobre las cards nuevas para que no "se resetee" visualmente.
        // Ademas se guarda/restaura el scroll en el mismo ciclo, antes del repaint.
        if (window.Sys && Sys.WebForms && Sys.WebForms.PageRequestManager) {
            var prm = Sys.WebForms.PageRequestManager.getInstance();
            var scrollGuardado = 0;
            prm.add_beginRequest(function () {
                scrollGuardado = window.pageYOffset;
            });
            prm.add_endRequest(function () {
                aplicarFiltros();
                var raiz = document.documentElement;
                var comportamientoPrevio = raiz.style.scrollBehavior;
                raiz.style.scrollBehavior = 'auto';
                window.scrollTo(0, scrollGuardado);
                raiz.style.scrollBehavior = comportamientoPrevio;
            });
        }
    </script>

</asp:Content>
