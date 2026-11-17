<%@ Page Title="" Language="C#" MasterPageFile="~/Master.Master" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="CatalogoWEB.Login" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <div class="auth-wrapper">
        <!-- DefaultButton: Enter en los campos envia este formulario (y no el boton de sesion del navbar) -->
        <asp:Panel runat="server" CssClass="auth-card" DefaultButton="btnIngresar">

            <!-- Encabezados -->
            <div class="auth-mark">Catálogo</div>
            <h1 class="auth-title">Ingresá tu email y contraseña</h1>
            <p class="auth-sub">Iniciá sesión para guardar favoritos y armar tu carrito.</p>

            <!-- TextBox de correo electronico con sus validaciones en el front -->
            <div class="mb-3">
                <asp:Label runat="server" CssClass="form-label" Text="Correo electrónico" AssociatedControlID="txtBoxEmail" />
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
                <asp:Label runat="server" CssClass="form-label" Text="Contraseña" AssociatedControlID="txtBoxContrasena" />
                <asp:TextBox runat="server" ID="txtBoxContrasena" CssClass="form-control"
                    TextMode="Password" placeholder="••••••••" MaxLength="20" />
                <asp:Label Text="La contraseña es obligatoria." runat="server"
                    ID="lblValidacionContrasena" Visible="false" CssClass="validation-error" />
                <asp:RequiredFieldValidator ErrorMessage="La contraseña es obligatoria."
                    ControlToValidate="txtBoxContrasena" runat="server" CssClass="validation-error" />
            </div>

            <!-- Boton de ingresar -->
            <div class="auth-actions">
                <asp:Button ID="btnIngresar" runat="server" Text="Ingresar"
                    CssClass="btn-primary" OnClick="btnIngresar_Click" />
            </div>
            <asp:Label Text="" runat="server" ID="lblMensajeValidacion"
                CssClass="validation-error auth-message" />

            <div class="auth-footer">
                ¿No tenés cuenta? <a href="Registrarse.aspx">Registrate</a>
            </div>

        </asp:Panel>
    </div>

</asp:Content>
