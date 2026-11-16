<%@ Page Title="" Language="C#" MasterPageFile="~/Master.Master" AutoEventWireup="true" CodeBehind="Detalle.aspx.cs" Inherits="CatalogoWEB.Detalle" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <div class="back-row">
        <asp:Button ID="btnDetalleVolver" Text="← Volver al catálogo" runat="server"
            OnClick="btnDetalleVolver_Click" CssClass="btn-ghost" />
    </div>

    <%if (ArticuloSeleccionado != null)
        {%>
            <div class="pdp">
                <div class="pdp-media">
                    <img src='<%: string.IsNullOrEmpty(ArticuloSeleccionado.UrlImagen) ? "" : ResolveUrl(ArticuloSeleccionado.UrlImagen) %>'
                        alt='<%: ArticuloSeleccionado.Nombre %>'
                        onerror="this.onerror=null; this.src='data:image/svg+xml,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 width=%22400%22 height=%22400%22%3E%3Crect width=%22400%22 height=%22400%22 fill=%22%23f5f5f5%22/%3E%3Ctext x=%2250%25%22 y=%2250%25%22 dominant-baseline=%22middle%22 text-anchor=%22middle%22 font-family=%22sans-serif%22 font-size=%2216%22 fill=%22%239e9ea0%22%3ESin imagen%3C/text%3E%3C/svg%3E';" />
                </div>

                <div class="pdp-info">
                    <h1 class="pdp-title"><%: ArticuloSeleccionado.Nombre %></h1>
                    <p class="pdp-meta"><%: ArticuloSeleccionado.Categoria %> · <%: ArticuloSeleccionado.Marca %></p>

                    <p class="pdp-price">$<%: ArticuloSeleccionado.Precio.ToString("N2") %></p>
                    <p class='<%= ArticuloSeleccionado.Stock > 0 && ArticuloSeleccionado.Stock <= 5 ? "pdp-stock pdp-stock--bajo" : "pdp-stock" %>'>
                        <%: ArticuloSeleccionado.Stock == 0 ? "Sin stock" : (ArticuloSeleccionado.Stock <= 5 ? "Últimas unidades · " + ArticuloSeleccionado.Stock + " en stock" : ArticuloSeleccionado.Stock + " en stock") %>
                    </p>

                    <p class="pdp-desc"><%: ArticuloSeleccionado.Descripcion %></p>

                    <%if (!string.IsNullOrEmpty(ArticuloSeleccionado.Codigo))
                        {%>
                    <p class="pdp-code">Código: <%: ArticuloSeleccionado.Codigo %></p>
                    <%}%>
                </div>
            </div>
    <%}
    else
    {%>
        <div class="empty-state">
            <i class="bi bi-bag"></i>
            <p>No se seleccionó ningún artículo para mostrar.</p>
            <a href="Default.aspx" class="btn-primary">Ir al catálogo</a>
        </div>
    <%}%>
</asp:Content>
