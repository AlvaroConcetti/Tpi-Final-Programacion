<%@ Page Title="" Language="C#" MasterPageFile="~/Master.Master" AutoEventWireup="true" CodeBehind="Historial.aspx.cs" Inherits="CatalogoWEB.Historial" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <asp:ScriptManager runat="server" />

    <div class="page-header">
        <div>
            <h1 class="page-title">Historial de compras</h1>
            <p class="page-subtitle">Tus compras confirmadas</p>
        </div>
    </div>

    <div style="margin-bottom: 1.25rem;">
        <asp:Button ID="btnHistorialVolver" Text="← Volver al carrito" runat="server"
            OnClick="btnHistorialVolver_Click" CssClass="btn-ghost" Style="padding-left: 0;" />
    </div>

    <asp:UpdatePanel runat="server">
        <ContentTemplate>

            <asp:Repeater runat="server" ID="repCompras">
                <ItemTemplate>
                    <div class="panel order-card">
                        <div class="order-card-header">
                            <div>
                                <strong>Pedido #<%#Eval("Id")%></strong>
                                <span class="order-card-meta"><%#Eval("FechaConfirmacion", "{0:dd/MM/yyyy HH:mm}")%></span>
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
                    </div>
                </ItemTemplate>
            </asp:Repeater>

            <asp:Panel ID="pnlVacio" runat="server" CssClass="empty-state" Visible="false">
                <i class="bi bi-receipt me-1"></i>
                <p style="color: var(--text-secondary); font-size: 14px; margin: 0;">Todavía no tenés compras confirmadas.</p>
            </asp:Panel>

        </ContentTemplate>
    </asp:UpdatePanel>

</asp:Content>
