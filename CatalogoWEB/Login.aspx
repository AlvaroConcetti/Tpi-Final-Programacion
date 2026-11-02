<%@ Page Title="" Language="C#" MasterPageFile="~/Master.Master" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="CatalogoWEB.Login" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <div class="auth-wrapper">
        <div class="auth-card">

            <!-- Encabezados -->
            <h2 class="auth-title">Bienvenido</h2>
            <p class="auth-sub">Iniciá sesión para continuar</p>

            <!-- TextBox de correo electronico con sus validaciones en el front -->
            <div class="mb-3">
                <asp:Label runat="server" CssClass="form-label" Text="Correo electrónico" />
                <asp:TextBox runat="server" ID="txtBoxEmail" CssClass="form-control"
                    placeholder="nombre@ejemplo.com" MaxLength="100" />
                <asp:Label Text="Campo obligatorio. Indicá un email." runat="server"
                    ID="lblValidacionEmail" Visible="false" CssClass="validation-error" />
                <asp:RegularExpressionValidator Display="Dynamic"
                    ErrorMessage="Colocá un email válido."
                    ControlToValidate="txtBoxEmail" runat="server"
                    CssClass="validation-error" ValidateEmptyText="false"
                    ValidationExpression="^([\w-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([\w-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$" />
                <asp:RequiredFieldValidator ErrorMessage="El email es obligatorio."
                    Display="Dynamic" ControlToValidate="txtBoxEmail"
                    runat="server" CssClass="validation-error" />
            </div>

            <!-- TextBox de contrasena con sus validaciones en el front -->
            <div class="mb-4">
                <asp:Label runat="server" CssClass="form-label" Text="Contraseña" />
                <asp:TextBox runat="server" ID="txtBoxContrasena" CssClass="form-control"
                    TextMode="Password" placeholder="••••••••" MaxLength="20" />
                <asp:Label Text="La contraseña es obligatoria." runat="server"
                    ID="lblValidacionContrasena" Visible="false" CssClass="validation-error" />
                <asp:RequiredFieldValidator ErrorMessage="La contraseña es obligatoria."
                    ControlToValidate="txtBoxContrasena" runat="server" CssClass="validation-error" />
            </div>

            <!-- Boton de ingresar -->
            <asp:Button ID="btnIngresar" runat="server" Text="Ingresar"
                CssClass="btn-primary" OnClick="btnIngresar_Click"
                style="width:100%; padding:0.6rem;" />
            <asp:Label Text="" runat="server" ID="lblMensajeValidacion"
                CssClass="validation-error" style="margin-top:0.5rem; text-align:center;" />

            <div class="auth-footer">
                ¿No tenés cuenta? <a href="Registrarse.aspx">Registrate</a>
            </div>

        </div>
    </div>

</asp:Content>
