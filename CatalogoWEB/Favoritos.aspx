<%@ Page Title="" Language="C#" MasterPageFile="~/Master.Master" AutoEventWireup="true" CodeBehind="Favoritos.aspx.cs" Inherits="CatalogoWEB.Favoritos" MaintainScrollPositionOnPostback="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<asp:ScriptManager runat="server" />
    <div class="page-header">
        <div>
            <h1 class="page-title">Favoritos</h1>
            <p class="page-subtitle">Tus artículos guardados</p>
        </div>
    </div>

    <div style="margin-bottom: 1.25rem;">
        <asp:Button ID="btnFavoritoVolver" Text="← Volver al catálogo" runat="server"
            OnClick="btnFavoritoVolver_Click" CssClass="btn-ghost" Style="padding-left: 0;" />
    </div>

    <asp:UpdatePanel runat="server">
        <ContentTemplate>
            <div class="row row-cols-1 row-cols-sm-2 row-cols-lg-3 row-cols-xl-4 g-3">

                <asp:Repeater runat="server" ID="repRepetidorFavoritos" OnItemCommand="repRepetidorFavoritos_ItemCommand">
                    <ItemTemplate>
                        <div class="col">
                            <div class="catalog-card h-100">
                                <img src="<%#Eval("UrlImagen")%>" alt="<%#Eval("Nombre")%>" onerror="this.onerror=null;this.src='data:image/svg+xml,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 width=%22400%22 height=%22300%22%3E%3Crect width=%22400%22 height=%22300%22 fill=%22%23edeae3%22/%3E%3Ctext x=%2250%25%22 y=%2250%25%22 dominant-baseline=%22middle%22 text-anchor=%22middle%22 font-family=%22sans-serif%22 font-size=%2214%22 fill=%22%23a09d97%22%3ESin imagen%3C/text%3E%3C/svg%3E'" />

                                <asp:LinkButton ID="btnFavorito" runat="server"
                                    CommandArgument='<%# Eval("Id") %>'
                                    CommandName="QuitarFavorito"
                                    CssClass="fav-btn fav-btn--activo">
                                    <i class="bi bi-heart-fill"></i>
                                </asp:LinkButton>

                                <div class="catalog-card-body">
                                    <p class="catalog-card-title"><%#Eval("Nombre")%></p>
                                    <p class="catalog-card-desc"><%#Eval("Descripcion")%></p>
                                    <p style="font-size: 14px; font-weight: 600; color: var(--text-primary); margin: 0 0 0.85rem;">$<%#Eval("Precio", "{0:N2}")%></p>
                                    <asp:Button ID="btnDetalle" Text="Ver detalle →" runat="server"
                                        OnClick="btnDetalle_Click"
                                        CommandArgument='<%#Eval("Id")%>'
                                        CommandName="ArticuloId"
                                        CssClass="btn-outline"
                                        Style="width: 100%;" />
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
        <asp:Label ID="lblParrafo" Text="" runat="server" Style="color: var(--text-secondary); font-size: 14px; display: block;" />
    </div>

</asp:Content>
