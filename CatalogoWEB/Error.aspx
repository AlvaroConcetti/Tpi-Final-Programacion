<%@ Page Title="" Language="C#" MasterPageFile="~/Master.Master" AutoEventWireup="true" CodeBehind="Error.aspx.cs" Inherits="CatalogoWEB.Error" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <div class="error-page">
        <h1 class="page-title">Ocurrió un problema</h1>
        <asp:Label ID="lblError" Text="" runat="server" CssClass="error-detail" />
        <a href="Default.aspx" class="btn-primary">Volver al catálogo</a>
    </div>

</asp:Content>
