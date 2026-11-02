<%@ Page Title="" Language="C#" MasterPageFile="~/Master.Master" AutoEventWireup="true" CodeBehind="Carrito.aspx.cs" Inherits="CatalogoWEB.Carrito" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<asp:ScriptManager runat="server" />

    <div class="page-header">
        <div>
            <h1 class="page-title">Mi Carrito</h1>
            <p class="page-subtitle">Tus artiuculos en el carrito guardados</p>
        </div>
    </div>

    <!-- Esto lo hizo claude code ↓ -->
    <!-- Notificacion flotante que se muestra al agregar una unidad desde el "+" -->
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

    <div style="margin-bottom: 1.25rem; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 0.5rem;">
        <asp:Button ID="btnCarritoVolver" Text="← Volver al catálogo" runat="server"
            OnClick="btnCarritoVolver_Click" CssClass="btn-ghost" Style="padding-left: 0;" />
        <asp:Button ID="btnVerHistorial" Text="Ver historial de compras" runat="server"
            OnClick="btnVerHistorial_Click" CssClass="btn-outline" />
    </div>

    <!-- Esto lo hizo claude code ↓ -->
    <asp:UpdatePanel runat="server">
        <ContentTemplate>
            <div class="row row-cols-1 row-cols-sm-2 row-cols-lg-3 row-cols-xl-4 g-3">
                <asp:Repeater runat="server" ID="repRepetidor">
                    <ItemTemplate>
                        <div class="col">
                            <!-- Toda la card es clickeable (salvo .no-card-click) y dispara el postback de btnDetalle -->
                            <div class="catalog-card h-100 catalog-card--cart" onclick="clickCard(event, this)">
                                <img src="<%#Eval("Articulo.UrlImagen")%>" alt="<%#Eval("Articulo.Nombre")%>" onerror="this.onerror=null;this.src='data:image/svg+xml,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 width=%22400%22 height=%22300%22%3E%3Crect width=%22400%22 height=%22300%22 fill=%22%231a1f2e%22/%3E%3Ctext x=%2250%25%22 y=%2250%25%22 dominant-baseline=%22middle%22 text-anchor=%22middle%22 font-family=%22sans-serif%22 font-size=%2214%22 fill=%22%23404e68%22%3ESin imagen%3C/text%3E%3C/svg%3E'" />
                                <div class="catalog-card-body">
                                    <p class="catalog-card-title"><%#Eval("Articulo.Nombre")%></p>
                                    <p style="font-size: 14px; font-weight: 600; color: var(--price-color); margin: 0 0 0.2rem;">$<%#Eval("Articulo.Precio", "{0:N2}")%></p>
                                    <p class="stock-info">Stock disponible: <%#Eval("Articulo.Stock")%></p>
                                    <p class="cart-subtotal">Subtotal: $<%#Eval("Subtotal", "{0:N2}")%></p>

                                    <!-- Boton oculto: hace el postback real de "Ver detalle" cuando se clickea la card -->
                                    <asp:Button ID="btnDetalle" runat="server"
                                        OnClick="btnDetalle_Click"
                                        CommandArgument='<%#Eval("Articulo.Id")%>'
                                        CommandName="ArticuloId"
                                        CssClass="card-click-target"
                                        Style="display: none;" />

                                    <!-- Mismo selector de cantidad que en el Catalogo. Bajar a 0 saca el item directo, sin confirmacion -->
                                    <asp:Panel ID="pnlStepper" runat="server" CssClass="qty-stepper no-card-click">
                                        <asp:LinkButton ID="btnMenos" runat="server" CssClass="qty-btn"
                                            OnClick="btnMenosCantidad_Click"
                                            CommandArgument='<%#Eval("Articulo.Id")%>'>
                                    <i class="bi bi-dash"></i>
                                </asp:LinkButton>
                                        <span class="qty-value"><%#Eval("Cantidad")%> en tu carrito</span>
                                        <asp:LinkButton ID="btnMas" runat="server"
                                            CssClass='<%# (int)Eval("Cantidad") < (int)Eval("Articulo.Stock") ? "qty-btn" : "qty-btn qty-btn--disabled" %>'
                                            OnClick="btnMasCantidad_Click"
                                            CommandArgument='<%#Eval("Articulo.Id")%>'
                                            Enabled='<%# (int)Eval("Cantidad") < (int)Eval("Articulo.Stock") %>'>
                                    <i class="bi bi-plus"></i>
                                </asp:LinkButton>
                                    </asp:Panel>

                                    <!-- No hace postback directo: abre el modal de confirmacion (ver mas abajo).-->
                                    <asp:Button ID="btnQuitarDelCarrito" Text="Quitar del carrito" runat="server"
                                        CssClass="btn-danger-soft no-card-click"
                                        UseSubmitBehavior="false"
                                        OnClientClick='<%# "return mostrarModalQuitar(event, " + Eval("Articulo.Id") + ");" %>'
                                        Style="width: 100%; margin-top: 0.5rem;" />
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>

            <asp:Panel ID="pnlFooter" runat="server" CssClass="cart-footer" Visible="false">
                <span class="cart-total">Total:
                    <asp:Label ID="lblTotal" Text="$0" runat="server" /></span>
                <asp:Button ID="btnIniciarCompra" Text="Continuar compra" runat="server"
                    OnClick="btnIniciarCompra_Click" CssClass="btn-primary"
                    OnClientClick="return mostrarModalContinuarCompra(event, this);" />
            </asp:Panel>

            <div class="empty-state">
                <i class="bi bi-cart me-1"></i>
                <asp:Label ID="lblParrafo" Text="" runat="server" Style="color: var(--text-secondary); font-size: 14px; display: block;" />
            </div>

            <asp:HiddenField ID="hdnIdAQuitar" runat="server" />
            <asp:Button ID="btnQuitarConfirmadoOculto" runat="server" OnClick="btnQuitarDelCarrito_Click" Style="display: none;" />

        </ContentTemplate>
    </asp:UpdatePanel>

    <!-- Esto lo hizo claude code ↓ -->
    <!-- Modal de confirmacion para eliminar un articulo del carrito -->
    <div id="modalConfirmarQuitar" class="modal-overlay" onclick="cancelarQuitar()">
        <div class="modal-box" onclick="event.stopPropagation()">
            <p class="modal-text">¿Querés quitar este artículo del carrito?</p>
            <div class="modal-actions">
                <button type="button" class="btn-outline" onclick="cancelarQuitar()">Cancelar</button>
                <button type="button" class="btn-primary" onclick="confirmarQuitar()">Confirmar</button>
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

    <!-- Esto lo hizo claude code ↓ -->
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

    <!-- Esto lo hizo claude code ↓ -->
    <script type="text/javascript">
        // Guarda y restaura el scroll en cada postback parcial del UpdatePanel
        // (mismo mecanismo que en el catalogo). El override de scroll-behavior es
        // porque Bootstrap pone smooth en :root y animaria la restauracion.
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
