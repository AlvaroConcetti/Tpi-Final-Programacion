<%@ Page Title="" Language="C#" MasterPageFile="~/Master.Master" AutoEventWireup="true" CodeBehind="Favoritos.aspx.cs" Inherits="CatalogoWEB.Favoritos" MaintainScrollPositionOnPostback="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<asp:ScriptManager runat="server" />

    <div class="back-row">
        <asp:Button ID="btnFavoritoVolver" Text="← Volver al catálogo" runat="server"
            OnClick="btnFavoritoVolver_Click" CssClass="btn-ghost" />
    </div>

    <div class="page-header">
        <div>
            <h1 class="page-title">Favoritos</h1>
            <p class="page-subtitle">Tus artículos guardados</p>
        </div>
    </div>

    <asp:UpdatePanel runat="server">
        <ContentTemplate>
            <div class="product-grid">

                <asp:Repeater runat="server" ID="repRepetidorFavoritos" OnItemCommand="repRepetidorFavoritos_ItemCommand">
                    <ItemTemplate>
                        <div class="product-item">
                            <!-- Toda la card es clickeable (salvo el corazon) y abre el detalle -->
                            <div class="product-card" onclick="clickCard(event, this)">
                                <div class="product-media">
                                    <img src="<%#Eval("UrlImagen")%>" alt="<%#Eval("Nombre")%>" loading="lazy" onerror="this.onerror=null;this.src='data:image/svg+xml,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 width=%22400%22 height=%22400%22%3E%3Crect width=%22400%22 height=%22400%22 fill=%22%23f5f5f5%22/%3E%3Ctext x=%2250%25%22 y=%2250%25%22 dominant-baseline=%22middle%22 text-anchor=%22middle%22 font-family=%22sans-serif%22 font-size=%2216%22 fill=%22%239e9ea0%22%3ESin imagen%3C/text%3E%3C/svg%3E'" />

                                    <asp:LinkButton ID="btnFavorito" runat="server"
                                        CommandArgument='<%# Eval("Id") %>'
                                        CommandName="QuitarFavorito"
                                        CssClass="fav-btn fav-btn--activo no-card-click"
                                        ToolTip="Quitar de favoritos">
                                        <i class="bi bi-heart-fill"></i>
                                    </asp:LinkButton>
                                </div>

                                <div class="product-info">
                                    <p class="product-name"><%#Eval("Nombre")%></p>
                                    <p class="product-meta"><%#Eval("Categoria")%> · <%#Eval("Marca")%></p>
                                    <p class="product-desc"><%#Eval("Descripcion")%></p>
                                    <p class="product-price">$<%#Eval("Precio", "{0:N2}")%></p>

                                    <!-- Boton oculto: hace el postback real de "Ver detalle" cuando se clickea la card -->
                                    <asp:Button ID="btnDetalle" runat="server"
                                        OnClick="btnDetalle_Click"
                                        CommandArgument='<%#Eval("Id")%>'
                                        CommandName="ArticuloId"
                                        CssClass="card-click-target"
                                        Style="display: none;" />
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>

    <div class="empty-state">
        <i class="bi bi-heart"></i>
        <asp:Label ID="lblParrafo" Text="" runat="server" />
    </div>

</asp:Content>
