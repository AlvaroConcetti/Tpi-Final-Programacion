<%@ Page Title="" Language="C#" MasterPageFile="~/Master.Master" AutoEventWireup="true" CodeBehind="Perfil.aspx.cs" Inherits="CatalogoWEB.Perfil" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <div class="page-header">
        <div>
            <h1 class="page-title">Mi perfil</h1>
            <p class="page-subtitle">Actualizá tus datos y tu contraseña</p>
        </div>
    </div>

    <div class="profile-grid">

        <!-- Datos personales -->
        <asp:Panel runat="server" CssClass="form-card" DefaultButton="btnGuardarDatos">
            <h2 class="form-card-title">Datos personales</h2>

            <div class="form-field">
                <asp:Label runat="server" CssClass="form-label" Text="Correo electrónico" AssociatedControlID="txtBoxEmail" />
                <asp:TextBox runat="server" ID="txtBoxEmail" CssClass="form-control" Enabled="false" />
            </div>

            <div class="form-grid-2 form-field">
                <div>
                    <asp:Label runat="server" CssClass="form-label" Text="Nombre" AssociatedControlID="txtBoxNombre" />
                    <asp:TextBox runat="server" ID="txtBoxNombre" CssClass="form-control" MaxLength="50" />
                </div>
                <div>
                    <asp:Label runat="server" CssClass="form-label" Text="Apellido" AssociatedControlID="txtBoxApellido" />
                    <asp:TextBox runat="server" ID="txtBoxApellido" CssClass="form-control" MaxLength="50" />
                </div>
            </div>

            <div class="form-card-actions">
                <asp:Label ID="lblMensajeDatos" runat="server" CssClass="form-message" />
                <asp:Button ID="btnGuardarDatos" runat="server" Text="Guardar datos"
                    CssClass="btn-primary" OnClick="btnGuardarDatos_Click" ValidationGroup="Datos" />
            </div>
        </asp:Panel>

        <!-- Cambio de contraseña -->
        <asp:Panel runat="server" CssClass="form-card" DefaultButton="btnCambiarContrasena">
            <h2 class="form-card-title">Cambiar contraseña</h2>

            <div class="form-field">
                <asp:Label runat="server" CssClass="form-label" Text="Contraseña actual" AssociatedControlID="txtBoxContrasenaActual" />
                <asp:TextBox runat="server" ID="txtBoxContrasenaActual" CssClass="form-control"
                    TextMode="Password" MaxLength="20" />
                <asp:RequiredFieldValidator ErrorMessage="Ingresá tu contraseña actual."
                    Display="Dynamic" ControlToValidate="txtBoxContrasenaActual" ValidationGroup="Contrasena"
                    runat="server" CssClass="validation-error" />
            </div>

            <div class="form-field">
                <asp:Label runat="server" CssClass="form-label" Text="Contraseña nueva" AssociatedControlID="txtBoxContrasenaNueva" />
                <asp:TextBox runat="server" ID="txtBoxContrasenaNueva" CssClass="form-control"
                    TextMode="Password" MaxLength="20" />
                <p class="form-hint">Mínimo 6 caracteres, con 1 mayúscula, 1 minúscula y 1 número.</p>
                <asp:RequiredFieldValidator ErrorMessage="Ingresá la contraseña nueva."
                    Display="Dynamic" ControlToValidate="txtBoxContrasenaNueva" ValidationGroup="Contrasena"
                    runat="server" CssClass="validation-error" />
            </div>

            <div class="form-field">
                <asp:Label runat="server" CssClass="form-label" Text="Confirmá la contraseña nueva" AssociatedControlID="txtBoxConfirmarContrasena" />
                <asp:TextBox runat="server" ID="txtBoxConfirmarContrasena" CssClass="form-control"
                    TextMode="Password" MaxLength="20" />
                <asp:CompareValidator ErrorMessage="Las contraseñas no coinciden."
                    Display="Dynamic" ControlToValidate="txtBoxConfirmarContrasena" ControlToCompare="txtBoxContrasenaNueva"
                    ValidationGroup="Contrasena" runat="server" CssClass="validation-error" />
            </div>

            <div class="form-card-actions">
                <asp:Label ID="lblMensajeContrasena" runat="server" CssClass="form-message" />
                <asp:Button ID="btnCambiarContrasena" runat="server" Text="Cambiar contraseña"
                    CssClass="btn-primary" OnClick="btnCambiarContrasena_Click" ValidationGroup="Contrasena" />
            </div>
        </asp:Panel>

    </div>

</asp:Content>
