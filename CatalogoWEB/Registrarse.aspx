<%@ Page Title="" Language="C#" MasterPageFile="~/Master.Master" AutoEventWireup="true" CodeBehind="Registrarse.aspx.cs" Inherits="CatalogoWEB.Registrarse" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <div class="auth-wrapper">
        <div class="auth-card">

            <!-- Encabezados -->
            <h2 class="auth-title">Crear cuenta</h2>
            <p class="auth-sub">Completá tus datos para registrarte</p>

            <!-- TextBox de correo electronico con sus validaciones en el front -->
            <div class="mb-3">
                <asp:Label runat="server" CssClass="form-label" Text="Correo electrónico" />
                <asp:TextBox runat="server" ID="txtBoxEmail" CssClass="form-control"
                    placeholder="nombre@ejemplo.com" MaxLength="100" />
                <asp:RequiredFieldValidator ErrorMessage="El email es obligatorio."
                    Display="Dynamic" ControlToValidate="txtBoxEmail"
                    runat="server" CssClass="validation-error" />
                <asp:RegularExpressionValidator Display="Dynamic"
                    ErrorMessage="Colocá un email válido."
                    ControlToValidate="txtBoxEmail" runat="server"
                    CssClass="validation-error" ValidateEmptyText="false"
                    ValidationExpression="^([\w-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([\w-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$" />
            </div>

            <!-- TextBox de contrasena con sus validaciones en el front -->
            <div class="mb-3">
                <asp:Label runat="server" CssClass="form-label" Text="Contraseña" />
                <asp:TextBox runat="server" ID="txtBoxContrasena" CssClass="form-control"
                    TextMode="Password" placeholder="••••••••" MaxLength="20" />
                <asp:RequiredFieldValidator ErrorMessage="La contraseña es obligatoria."
                    Display="Dynamic" ControlToValidate="txtBoxContrasena"
                    runat="server" CssClass="validation-error" />
            </div>

            <!-- TextBox de confrimar contrasena con sus validaciones en el front -->
            <div class="mb-4">
                <asp:Label runat="server" CssClass="form-label" Text="Confirmá tu contraseña" />
                <asp:TextBox runat="server" ID="txtBoxconfirmarContrasena" CssClass="form-control"
                    TextMode="Password" placeholder="••••••••" MaxLength="20" />
                <asp:RequiredFieldValidator ErrorMessage="Confirmá tu contraseña."
                    Display="Dynamic" ControlToValidate="txtBoxconfirmarContrasena"
                    runat="server" CssClass="validation-error" />
            </div>

            <!-- Boton de crear cuenta -->
            <asp:Button ID="btnCrearCuenta" runat="server" Text="Crear cuenta"
                CssClass="btn-primary" OnClick="btnCrearCuenta_Click"
                Style="width: 100%; padding: 0.6rem;" />
            <asp:Label Text="" runat="server" ID="lblMensajeValidacion"
                CssClass="validation-error" Style="margin-top: 0.5rem; text-align: center;" />

            <div class="auth-footer">
                ¿Ya tenés cuenta? <a href="Login.aspx">Iniciá sesión</a>
            </div>

        </div>
    </div>

</asp:Content>
