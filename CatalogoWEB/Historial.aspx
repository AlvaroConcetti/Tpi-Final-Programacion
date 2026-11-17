<%@ Page Title="" Language="C#" MasterPageFile="~/Master.Master" AutoEventWireup="true" CodeBehind="Historial.aspx.cs" Inherits="CatalogoWEB.Historial" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <div class="back-row">
        <asp:Button ID="btnHistorialVolver" Text="← Volver al catálogo" runat="server"
            OnClick="btnHistorialVolver_Click" CssClass="btn-ghost" />
    </div>

    <div class="page-header">
        <div>
            <h1 class="page-title">Mis pedidos</h1>
            <p class="page-subtitle">Seguí el estado de cada pedido que mandaste por WhatsApp</p>
        </div>
    </div>

    <asp:Repeater runat="server" ID="repCompras">
        <ItemTemplate>
            <div class="panel order-card">
                <div class="order-card-header">
                    <div>
                        <strong>Pedido #<%#Eval("Id")%></strong>
                        <span class='<%# ClaseEstado(Eval("Estado")) %>'><%#: Eval("Estado") %></span>
                        <span class="order-card-meta"><%#Eval("FechaPedido", "{0:dd/MM/yyyy HH:mm}")%></span>
                    </div>
                    <span class="order-card-total">Total: $<%#Eval("Total", "{0:N2}")%></span>
                </div>

                <asp:Repeater runat="server" ID="repDetalle" DataSource='<%#Eval("Detalle")%>'>
                    <ItemTemplate>
                        <div class="order-line">
                            <span><%#: Eval("Articulo.Nombre") %> x<%#Eval("Cantidad")%></span>
                            <span>$<%#Eval("Subtotal", "{0:N2}")%></span>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>

                <div class="order-card-foot">
                    <p class="order-note"><%#: NotaEstado(Container.DataItem) %></p>
                    <!-- Solo en pedidos pendientes: vuelve a abrir WhatsApp con el mismo mensaje -->
                    <asp:PlaceHolder runat="server" Visible='<%# LinkReenviar(Container.DataItem) != "" %>'>
                        <a class="btn-outline" href='<%#: LinkReenviar(Container.DataItem) %>' target="_blank" rel="noopener">
                            <i class="bi bi-whatsapp"></i>Reenviar por WhatsApp
                        </a>
                    </asp:PlaceHolder>
                </div>
            </div>
        </ItemTemplate>
    </asp:Repeater>

    <asp:Panel ID="pnlVacio" runat="server" CssClass="empty-state" Visible="false">
        <i class="bi bi-bag"></i>
        <p>Todavía no hiciste ningún pedido.</p>
        <a href="Default.aspx" class="btn-primary">Ir al catálogo</a>
    </asp:Panel>

</asp:Content>
