<%@ Page Title="" Language="C#" MasterPageFile="~/Master.Master" AutoEventWireup="true" CodeBehind="Detalle.aspx.cs" Inherits="CatalogoWEB.Detalle" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <div style="margin-bottom: 1.25rem;">
        <asp:Button ID="btnDetalleVolver" Text="← Volver al catálogo" runat="server"
            OnClick="btnDetalleVolver_Click" CssClass="btn-ghost" Style="padding-left: 0;" />
    </div>

    <%if (ArticuloSeleccionado != null)
        {%>
            <div class="row g-5" style="max-width: 860px;">
                <div class="col-md-5">
                    <div style="border-radius: var(--radius-md); overflow: hidden; border: 1px solid var(--border);">
                        <img src='<%= string.IsNullOrEmpty(ArticuloSeleccionado.UrlImagen) ? "" : ResolveUrl(ArticuloSeleccionado.UrlImagen) %>'
                            alt='<%= ArticuloSeleccionado.Nombre %>'
                            style="width: 100%; aspect-ratio: 1; object-fit: cover; display: block;"
                            onerror="this.onerror=null; this.src='data:image/svg+xml,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 width=%22400%22 height=%22300%22%3E%3Crect width=%22400%22 height=%22300%22 fill=%22%221a1f2e%22/%3E%3Ctext x=%2250%25%22 y=%2250%25%22 dominant-baseline=%22middle%22 text-anchor=%22middle%22 font-family=%22sans-serif%22 font-size=%2214%22 fill=%22%23404e68%22%3ESin imagen%3C/text%3E%3C/svg%3E';" />
                    </div>
                </div>
                <div class="col-md-7 d-flex flex-column justify-content-center">
                    <span class="tag" style="margin-bottom: 0.75rem;">Artículo</span>
                    <h1 style="font-family: 'Playfair Display',serif; font-size: 2rem; font-weight: 400; letter-spacing: -0.02em; margin: 0 0 0.75rem; line-height: 1.2;">
                        <%:ArticuloSeleccionado.Nombre %>
                    </h1>
                    <p style="color: var(--text-secondary); font-size: 15px; line-height: 1.7; margin: 0;">
                        <%:ArticuloSeleccionado.Descripcion %>
                    </p>
                    <p style="font-size: 1.4rem; font-weight: 600; color: var(--price-color); margin: 1rem 0 0;">
                        $<%: ArticuloSeleccionado.Precio.ToString("N2") %>
                    </p>
                </div>
            </div>
    <%}
    else
    {%>
        <div class="alert alert-danger">
            <h2>No se seleccionó ningún artículo para mostrar.</h2>
            <a href="Default.aspx" class="btn btn-primary">Volver</a>
        </div>
    <%}%>
</asp:Content>
