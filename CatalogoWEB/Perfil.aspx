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

    <div class="row g-4" style="max-width: 900px;">

        <!-- Datos personales -->
        <div class="col-md-6">
            <div class="panel" style="padding: 1.25rem;">
                <p class="form-label mb-3">Datos personales</p>

                <div class="mb-3">
                    <asp:Label runat="server" CssClass="form-label" Text="Correo electrónico" />
                    <asp:TextBox runat="server" ID="txtBoxEmail" CssClass="form-control" Enabled="false" />
                </div>

                <div class="mb-3">
                    <asp:Label runat="server" CssClass="form-label" Text="Nombre" />
                    <asp:TextBox runat="server" ID="txtBoxNombre" CssClass="form-control" MaxLength="50" />
                </div>

                <div class="mb-3">
                    <asp:Label runat="server" CssClass="form-label" Text="Apellido" />
                    <asp:TextBox runat="server" ID="txtBoxApellido" CssClass="form-control" MaxLength="50" />
                </div>

                <asp:Button ID="btnGuardarDatos" runat="server" Text="Guardar datos"
                    CssClass="btn-primary" OnClick="btnGuardarDatos_Click" ValidationGroup="Datos" />
                <asp:Label ID="lblMensajeDatos" runat="server" CssClass="d-block mt-2" style="font-size: 14px;" />
            </div>
        </div>

        <!-- Cambio de contraseña -->
        <div class="col-md-6">
            <div class="panel" style="padding: 1.25rem;">
                <p class="form-label mb-3">Cambiar contraseña</p>

                <div class="mb-3">
                    <asp:Label runat="server" CssClass="form-label" Text="Contraseña actual" />
                    <asp:TextBox runat="server" ID="txtBoxContrasenaActual" CssClass="form-control"
                        TextMode="Password" MaxLength="20" />
                    <asp:RequiredFieldValidator ErrorMessage="Ingresá tu contraseña actual."
                        Display="Dynamic" ControlToValidate="txtBoxContrasenaActual" ValidationGroup="Contrasena"
                        runat="server" CssClass="validation-error" />
                </div>

                <div class="mb-3">
                    <asp:Label runat="server" CssClass="form-label" Text="Contraseña nueva" />
                    <asp:TextBox runat="server" ID="txtBoxContrasenaNueva" CssClass="form-control"
                        TextMode="Password" MaxLength="20" />
                    <asp:RequiredFieldValidator ErrorMessage="Ingresá la contraseña nueva."
                        Display="Dynamic" ControlToValidate="txtBoxContrasenaNueva" ValidationGroup="Contrasena"
                        runat="server" CssClass="validation-error" />
                </div>

                <div class="mb-3">
                    <asp:Label runat="server" CssClass="form-label" Text="Confirmá la contraseña nueva" />
                    <asp:TextBox runat="server" ID="txtBoxConfirmarContrasena" CssClass="form-control"
                        TextMode="Password" MaxLength="20" />
                    <asp:CompareValidator ErrorMessage="Las contraseñas no coinciden."
                        Display="Dynamic" ControlToValidate="txtBoxConfirmarContrasena" ControlToCompare="txtBoxContrasenaNueva"
                        ValidationGroup="Contrasena" runat="server" CssClass="validation-error" />
                </div>

                <asp:Button ID="btnCambiarContrasena" runat="server" Text="Cambiar contraseña"
                    CssClass="btn-primary" OnClick="btnCambiarContrasena_Click" ValidationGroup="Contrasena" />
                <asp:Label ID="lblMensajeContrasena" runat="server" CssClass="d-block mt-2" style="font-size: 14px;" />
            </div>
        </div>

    </div>

</asp:Content>
