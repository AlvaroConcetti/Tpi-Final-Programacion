<%@ Page Title="" Language="C#" MasterPageFile="~/Master.Master" AutoEventWireup="true" CodeBehind="Carrito.aspx.cs" Inherits="CatalogoWEB.Carrito" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<asp:ScriptManager runat="server" />

    <div class="back-row">
        <asp:Button ID="btnCarritoVolver" Text="← Volver al catálogo" runat="server"
            OnClick="btnCarritoVolver_Click" CssClass="btn-ghost" />
    </div>

    <div class="page-header">
        <div>
            <h1 class="page-title">Mi carrito</h1>
            <p class="page-subtitle">Revisá tus artículos antes de enviar el pedido</p>
        </div>
        <asp:Button ID="btnVerHistorial" Text="Ver historial de compras" runat="server"
            OnClick="btnVerHistorial_Click" CssClass="btn-outline" />
    </div>

    <!-- Notificacion flotante que se muestra al agregar una unidad desde el "+" -->
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
            <div class="cart-layout">

                <!-- Lista de articulos: una fila por item -->
                <div class="cart-items">
                    <asp:Repeater runat="server" ID="repRepetidor">
                        <ItemTemplate>
                            <!-- Toda la fila es clickeable (salvo .no-card-click) y dispara el postback de btnDetalle -->
                            <div class="cart-item" onclick="clickCard(event, this)">
                                <div class="cart-item-media">
                                    <img src="<%#: Eval("Articulo.UrlImagen") %>" alt="<%#: Eval("Articulo.Nombre") %>" loading="lazy" onerror="this.onerror=null;this.src='data:image/svg+xml,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 width=%22400%22 height=%22400%22%3E%3Crect width=%22400%22 height=%22400%22 fill=%22%23f5f5f5%22/%3E%3Ctext x=%2250%25%22 y=%2250%25%22 dominant-baseline=%22middle%22 text-anchor=%22middle%22 font-family=%22sans-serif%22 font-size=%2216%22 fill=%22%239e9ea0%22%3ESin imagen%3C/text%3E%3C/svg%3E'" />
                                </div>

                                <div class="cart-item-info">
                                    <div class="cart-item-head">
                                        <p class="cart-item-name"><%#: Eval("Articulo.Nombre") %></p>
                                        <p class="cart-item-price">$<%#Eval("Subtotal", "{0:N2}")%></p>
                                    </div>
                                    <p class="cart-item-meta">$<%#Eval("Articulo.Precio", "{0:N2}")%> c/u</p>
                                    <p class="cart-item-meta"><%#Eval("Articulo.Stock")%> en stock</p>

                                    <!-- Boton oculto: hace el postback real de "Ver detalle" cuando se clickea la fila -->
                                    <asp:Button ID="btnDetalle" runat="server"
                                        OnClick="btnDetalle_Click"
                                        CommandArgument='<%#Eval("Articulo.Id")%>'
                                        CommandName="ArticuloId"
                                        CssClass="card-click-target"
                                        Style="display: none;" />

                                    <div class="cart-item-controls">
                                        <!-- Mismo selector de cantidad que en el Catalogo. Bajar a 0 saca el item directo, sin confirmacion -->
                                        <asp:Panel ID="pnlStepper" runat="server" CssClass="qty-stepper no-card-click">
                                            <asp:LinkButton ID="btnMenos" runat="server" CssClass="qty-btn"
                                                OnClick="btnMenosCantidad_Click"
                                                CommandArgument='<%#Eval("Articulo.Id")%>' ToolTip="Quitar una unidad">
                                                <i class="bi bi-dash"></i>
                                            </asp:LinkButton>
                                            <span class="qty-value"><%#Eval("Cantidad")%></span>
                                            <asp:LinkButton ID="btnMas" runat="server"
                                                CssClass='<%# (int)Eval("Cantidad") < (int)Eval("Articulo.Stock") ? "qty-btn" : "qty-btn qty-btn--disabled" %>'
                                                OnClick="btnMasCantidad_Click"
                                                CommandArgument='<%#Eval("Articulo.Id")%>'
                                                Enabled='<%# (int)Eval("Cantidad") < (int)Eval("Articulo.Stock") %>'
                                                ToolTip="Agregar una unidad">
                                                <i class="bi bi-plus"></i>
                                            </asp:LinkButton>
                                        </asp:Panel>

                                        <!-- No hace postback directo: abre el modal de confirmacion (ver mas abajo) -->
                                        <asp:Button ID="btnQuitarDelCarrito" Text="Quitar" runat="server"
                                            CssClass="btn-ghost no-card-click"
                                            UseSubmitBehavior="false"
                                            OnClientClick='<%# "return mostrarModalQuitar(event, " + Eval("Articulo.Id") + ");" %>' />
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <!-- Resumen: solo visible si hay articulos -->
                <asp:Panel ID="pnlFooter" runat="server" CssClass="cart-summary" Visible="false">
                    <h2 class="cart-summary-title">Resumen</h2>
                    <div class="cart-summary-row">
                        <span>Total</span>
                        <asp:Label ID="lblTotal" Text="$0" runat="server" />
                    </div>
                    <asp:Button ID="btnIniciarCompra" Text="Continuar compra" runat="server"
                        OnClick="btnIniciarCompra_Click" CssClass="btn-primary btn-block btn-lg"
                        OnClientClick="return mostrarModalContinuarCompra(event, this);" />
                    <p class="cart-summary-note">El pedido se envía por WhatsApp para coordinarlo.</p>
                </asp:Panel>
            </div>

            <div class="empty-state">
                <i class="bi bi-bag"></i>
                <asp:Label ID="lblParrafo" Text="" runat="server" />
            </div>

            <asp:HiddenField ID="hdnIdAQuitar" runat="server" />
            <asp:Button ID="btnQuitarConfirmadoOculto" runat="server" OnClick="btnQuitarDelCarrito_Click" Style="display: none;" />

        </ContentTemplate>
    </asp:UpdatePanel>

    <!-- Modal de confirmacion para eliminar un articulo del carrito -->
    <div id="modalConfirmarQuitar" class="modal-overlay" onclick="cancelarQuitar()">
        <div class="modal-box" onclick="event.stopPropagation()">
            <p class="modal-text">¿Querés quitar este artículo del carrito?</p>
            <div class="modal-actions">
                <button type="button" class="btn-outline" onclick="cancelarQuitar()">Cancelar</button>
                <button type="button" class="btn-primary" onclick="confirmarQuitar()">Quitar</button>
            </div>
        </div>
    </div>
    <script type="text/javascript">
        var idAQuitarPendiente = null;
        function mostrarModalQuitar(evt, idArticulo) {
            if (evt) { evt.preventDefault(); evt.stopPropagation(); }
            idAQuitarPendiente = idArticulo;
            document.getElementById('modalConfirmarQuitar').classList.add('show');
            return false;
        }
        function cancelarQuitar() {
            idAQuitarPendiente = null;
            document.getElementById('modalConfirmarQuitar').classList.remove('show');
        }
        function confirmarQuitar() {
            document.getElementById('modalConfirmarQuitar').classList.remove('show');
            document.getElementById('<%= hdnIdAQuitar.ClientID %>').value = idAQuitarPendiente;
            document.getElementById('<%= btnQuitarConfirmadoOculto.ClientID %>').click();
        }
    </script>

    <!-- Modal de confirmacion antes de crear el Pedido y derivar a WhatsApp -->
    <div id="modalConfirmarContinuarCompra" class="modal-overlay" onclick="cancelarContinuarCompra()">
        <div class="modal-box" onclick="event.stopPropagation()">
            <p class="modal-text">Vas a ser redirigido a WhatsApp para enviar tu pedido. ¿Confirmás?</p>
            <div class="modal-actions">
                <button type="button" class="btn-outline" onclick="cancelarContinuarCompra()">Cancelar</button>
                <button type="button" class="btn-primary" onclick="confirmarContinuarCompra()">Confirmar</button>
            </div>
        </div>
    </div>
    <script type="text/javascript">
        var elementoContinuarCompra = null;
        function mostrarModalContinuarCompra(evt, elemento) {
            if (evt) { evt.preventDefault(); evt.stopPropagation(); }
            elementoContinuarCompra = elemento;
            document.getElementById('modalConfirmarContinuarCompra').classList.add('show');
            return false;
        }
        function cancelarContinuarCompra() {
            elementoContinuarCompra = null;
            document.getElementById('modalConfirmarContinuarCompra').classList.remove('show');
        }
        function confirmarContinuarCompra() {
            document.getElementById('modalConfirmarContinuarCompra').classList.remove('show');
            if (elementoContinuarCompra) {
                elementoContinuarCompra.onclick = null;
                elementoContinuarCompra.click();
            }
        }
    </script>

    <script type="text/javascript">
        // Guarda y restaura el scroll en cada postback parcial del UpdatePanel
        // (mismo mecanismo que en el catalogo).
        if (window.Sys && Sys.WebForms && Sys.WebForms.PageRequestManager) {
            var prm = Sys.WebForms.PageRequestManager.getInstance();
            var scrollGuardado = 0;
            prm.add_beginRequest(function () {
                scrollGuardado = window.pageYOffset;
            });
            prm.add_endRequest(function () {
                var raiz = document.documentElement;
                var comportamientoPrevio = raiz.style.scrollBehavior;
                raiz.style.scrollBehavior = 'auto';
                window.scrollTo(0, scrollGuardado);
                raiz.style.scrollBehavior = comportamientoPrevio;
            });
        }
    </script>
</asp:Content>
