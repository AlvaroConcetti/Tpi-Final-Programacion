<%@ Page Title="" Language="C#" MasterPageFile="~/Master.Master" AutoEventWireup="true" CodeBehind="PedidosCancelados.aspx.cs" Inherits="CatalogoWEB.PedidosCancelados" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <asp:ScriptManager runat="server" />

    <div class="page-header">
        <div>
            <h1 class="page-title">Pedidos cancelados</h1>
            <p class="page-subtitle">Reactivalos o borralos definitivamente</p>
        </div>
        <asp:Button ID="btnVolverVentas" Text="← Volver a Ventas" runat="server"
            OnClick="btnVolverVentas_Click" CssClass="btn-ghost" CausesValidation="false" />
    </div>

    <asp:UpdatePanel runat="server">
        <ContentTemplate>

            <!-- Repetidor con los datos de los pedidos cancelados -->
            <asp:Repeater runat="server" ID="repPedidos">
                <ItemTemplate>
                    <div class="panel order-card">
                        <div class="order-card-header">
                            <div>
                                <strong>Pedido #<%#Eval("Id")%></strong>
                                <span class="order-card-meta"><%#Eval("EmailUsuario")%> · <%#Eval("FechaPedido", "{0:dd/MM/yyyy HH:mm}")%></span>
                            </div>
                            <span class="order-card-total">Total: $<%#Eval("Total", "{0:N2}")%></span>
                        </div>

                        <asp:Repeater runat="server" ID="repDetalle" DataSource='<%#Eval("Detalle")%>'>
                            <ItemTemplate>
                                <div class="order-line">
                                    <span><%#Eval("Articulo.Nombre")%> x<%#Eval("Cantidad")%></span>
                                    <span>$<%#Eval("Subtotal", "{0:N2}")%></span>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>

                        <div class="order-card-actions">
                            <asp:Button Text="Dar de alta de nuevo" runat="server"
                                OnClick="btnReactivar_Click"
                                CommandArgument='<%#Eval("Id")%>'
                                CssClass="btn-outline"
                                CausesValidation="false"
                                OnClientClick="return mostrarModalAccionPedidoCancelado(event, this, 0);" />
                            <asp:Button Text="Borrar definitivamente" runat="server"
                                OnClick="btnEliminarDefinitivo_Click"
                                CommandArgument='<%#Eval("Id")%>'
                                CssClass="btn-danger-soft"
                                CausesValidation="false"
                                OnClientClick="return mostrarModalAccionPedidoCancelado(event, this, 1);" />
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>

            <asp:Panel ID="pnlVacio" runat="server" CssClass="empty-state" Visible="false">
                <i class="bi bi-bag-x me-1"></i>
                <p style="color: var(--text-secondary); font-size: 14px; margin: 0;">No hay pedidos cancelados.</p>
            </asp:Panel>

            <!-- Esto lo hizo claude code ↓ -->
            <!-- Modal de confirmacion compartido para "Dar de alta de nuevo" (0) y "Borrar definitivamente" (1, con advertencia extra) -->
            <div id="modalConfirmarAccionPedidoCancelado" class="modal-overlay" onclick="cancelarAccionPedidoCancelado()">
                <div class="modal-box" onclick="event.stopPropagation()">
                    <p class="modal-text" id="modalTextoAccionPedidoCancelado">¿Confirmás esta acción?</p>
                    <div class="modal-actions">
                        <button type="button" class="btn-outline" onclick="cancelarAccionPedidoCancelado()">Cancelar</button>
                        <button type="button" class="btn-primary" onclick="confirmarAccionPedidoCancelado()">Confirmar</button>
                    </div>
                </div>
            </div>
            <script type="text/javascript">
                var elementoAccionPedidoCancelado = null;
                function mostrarModalAccionPedidoCancelado(evt, elemento, tipoCodigo) {
                    if (evt) { evt.preventDefault(); evt.stopPropagation(); }
                    elementoAccionPedidoCancelado = elemento;
                    document.getElementById('modalTextoAccionPedidoCancelado').textContent = tipoCodigo === 0
                        ? '¿Querés dar de alta este pedido de nuevo? Va a volver a la pestaña de Ventas como pendiente.'
                        : '¿Estás seguro de que querés eliminar este pedido? Esta acción es permanente y no se puede deshacer.';
                    document.getElementById('modalConfirmarAccionPedidoCancelado').classList.add('show');
                    return false;
                }
                function cancelarAccionPedidoCancelado() {
                    elementoAccionPedidoCancelado = null;
                    document.getElementById('modalConfirmarAccionPedidoCancelado').classList.remove('show');
                }
                function confirmarAccionPedidoCancelado() {
                    document.getElementById('modalConfirmarAccionPedidoCancelado').classList.remove('show');
                    if (elementoAccionPedidoCancelado) {
                        elementoAccionPedidoCancelado.onclick = null;
                        elementoAccionPedidoCancelado.click();
                    }
                }
            </script>

        </ContentTemplate>
    </asp:UpdatePanel>

</asp:Content>
