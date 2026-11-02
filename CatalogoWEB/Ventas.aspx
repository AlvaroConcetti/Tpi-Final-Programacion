<%@ Page Title="" Language="C#" MasterPageFile="~/Master.Master" AutoEventWireup="true" CodeBehind="Ventas.aspx.cs" Inherits="CatalogoWEB.Ventas" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <asp:ScriptManager runat="server" />

    <div class="page-header">
        <div>
            <h1 class="page-title">Ventas</h1>
            <p class="page-subtitle">Confirmá o cancelá los pedidos pendientes</p>
        </div>
    </div>

    <asp:UpdatePanel runat="server">
        <ContentTemplate>

            <!-- TextBox para ingresar el numero de whatsapp encargado de recibir los pedidos + validaciones en el front -->
            <div class="panel" style="padding: 1.25rem; margin-bottom: 1.5rem; display: flex; justify-content: space-between; align-items: center; gap: 1rem; flex-wrap: wrap;">
                <div>
                    <label class="form-label">Teléfono de WhatsApp para recibir pedidos</label>
                    <div class="d-flex gap-2 flex-wrap" style="max-width: 420px;">
                        <asp:TextBox ID="txtBoxTelefono" runat="server" CssClass="form-control" placeholder="Ej: 5491122334455" MaxLength="20" />
                        <asp:Button ID="btnGuardarTelefono" runat="server" Text="Guardar" OnClick="btnGuardarTelefono_Click" CssClass="btn-primary" />
                    </div>
                    <asp:RequiredFieldValidator ID="valTelefonoRequerido" runat="server"
                        ControlToValidate="txtBoxTelefono" ErrorMessage="El teléfono es obligatorio."
                        CssClass="validation-error" Display="Dynamic" />
                    <asp:RegularExpressionValidator ID="valTelefonoFormato" runat="server"
                        ControlToValidate="txtBoxTelefono" ValidationExpression="^[1-9]\d{7,14}$"
                        ErrorMessage="Formato inválido. Usá solo números, con código de país, sin espacios ni guiones (ej: 5491122334455)."
                        CssClass="validation-error" Display="Dynamic" />
                    <asp:Label ID="lblMensajeTelefono" runat="server" Style="display: block; margin-top: 0.5rem; font-size: 13px; color: var(--success);" />
                </div>

                <!-- Boton para ir a la pagina de pedidos cancelados -->
                <asp:Button ID="btnPedidosCancelados" Text="Pedidos cancelados" runat="server"
                    OnClick="btnPedidosCancelados_Click" CssClass="btn-outline" CausesValidation="false" />
            </div>

            <asp:Label ID="lblMensaje" runat="server" CssClass="validation-error" Style="display: block; margin-bottom: 1rem;" />

            <!-- Repetidor con los datos del pedido -->
            <asp:Repeater runat="server" ID="repPedidos">
                <ItemTemplate>
                    <div class="panel order-card">
                        <div class="order-card-header">
                            <div>
                                <strong>Pedido #<%#Eval("Id")%></strong>
                                <span class="order-card-meta"><%#Eval("EmailUsuario")%> · <%#Eval("FechaPedido", "{0:dd/MM/yyyy HH:mm}")%></span>
                            </div>
                            <span class="order-card-total">Total: $<%#Eval("Total")%></span>
                        </div>

                        <asp:Repeater runat="server" ID="repDetalle" DataSource='<%#Eval("Detalle")%>'>
                            <ItemTemplate>
                                <div class="order-line">
                                    <span><%#Eval("Articulo.Nombre")%> x<%#Eval("Cantidad")%></span>
                                    <span>$<%#Eval("Subtotal")%></span>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>

                        <div class="order-card-actions">
                            <asp:Button Text="Confirmar venta" runat="server"
                                OnClick="btnConfirmar_Click"
                                CommandArgument='<%#Eval("Id")%>'
                                CssClass="btn-primary"
                                CausesValidation="false"
                                OnClientClick="return mostrarModalAccionVenta(event, this, 0);" />
                            <asp:Button Text="Cancelar pedido" runat="server"
                                OnClick="btnCancelar_Click"
                                CommandArgument='<%#Eval("Id")%>'
                                CssClass="btn-danger-soft"
                                CausesValidation="false"
                                OnClientClick="return mostrarModalAccionVenta(event, this, 1);" />
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>

            <asp:Panel ID="pnlVacio" runat="server" CssClass="empty-state" Visible="false">
                <i class="bi bi-bag-check me-1"></i>
                <p style="color: var(--text-secondary); font-size: 14px; margin: 0;">No hay pedidos pendientes.</p>
            </asp:Panel>

            <!-- Esto lo hizo claude code ↓ -->
            <!-- Modal de confirmacion compartido para "Confirmar venta" (0) y "Cancelar pedido" (1) -->
            <div id="modalConfirmarAccionVenta" class="modal-overlay" onclick="cancelarAccionVenta()">
                <div class="modal-box" onclick="event.stopPropagation()">
                    <p class="modal-text" id="modalTextoAccionVenta">¿Confirmás esta acción?</p>
                    <div class="modal-actions">
                        <button type="button" class="btn-outline" onclick="cancelarAccionVenta()">Cancelar</button>
                        <button type="button" class="btn-primary" onclick="confirmarAccionVenta()">Confirmar</button>
                    </div>
                </div>
            </div>
            <script type="text/javascript">
                var elementoAccionVenta = null;
                function mostrarModalAccionVenta(evt, elemento, tipoCodigo) {
                    if (evt) { evt.preventDefault(); evt.stopPropagation(); }
                    elementoAccionVenta = elemento;
                    document.getElementById('modalTextoAccionVenta').textContent = tipoCodigo === 0
                        ? '¿Confirmás esta venta? Se va a descontar el stock.'
                        : '¿Estás seguro de que querés cancelar este pedido?';
                    document.getElementById('modalConfirmarAccionVenta').classList.add('show');
                    return false;
                }
                function cancelarAccionVenta() {
                    elementoAccionVenta = null;
                    document.getElementById('modalConfirmarAccionVenta').classList.remove('show');
                }
                function confirmarAccionVenta() {
                    document.getElementById('modalConfirmarAccionVenta').classList.remove('show');
                    if (elementoAccionVenta) {
                        elementoAccionVenta.onclick = null;
                        elementoAccionVenta.click();
                    }
                }
            </script>

        </ContentTemplate>
    </asp:UpdatePanel>

</asp:Content>
