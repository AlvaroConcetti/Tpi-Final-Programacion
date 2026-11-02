<%@ Page Title="" Language="C#" MasterPageFile="~/Master.Master" AutoEventWireup="true" CodeBehind="CategoriasMarcas.aspx.cs" Inherits="CatalogoWEB.CategoriasMarcas" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <asp:ScriptManager runat="server" />

    <div class="page-header">
        <div>
            <h1 class="page-title">Categorías y Marcas</h1>
            <p class="page-subtitle">Gestioná las categorías y marcas del catálogo</p>
        </div>
        <asp:Button ID="btnVolverAdmin" Text="← Volver a Administración" runat="server"
            OnClick="btnVolverAdmin_Click" CssClass="btn-ghost" CausesValidation="false" />
    </div>

    <!-- Esto lo hizo claude code -->
    <!-- Alerta cuando se intenta eliminar una marca/categoria que todavia esta en uso -->
    <div id="toastAlerta" class="toast-notification toast-notification--error">
        <i class="bi bi-exclamation-triangle-fill me-1"></i>
        <span class="toast-text"></span>
    </div>
    <script type="text/javascript">
        function mostrarToastAlerta(mensaje) {
            var toast = document.getElementById('toastAlerta');
            if (!toast) return;
            toast.querySelector('.toast-text').textContent = mensaje;
            toast.classList.add('show');
            clearTimeout(toast._timer);
            toast._timer = setTimeout(function () {
                toast.classList.remove('show');
            }, 3200);
        }
    </script>

    <!-- Esto lo hizo claude code -->
    <!-- Notificacion pasiva al guardar la edicion de una marca o categoria -->
    <div id="toastCarrito" class="toast-notification">
        <i class="bi bi-check-circle-fill me-1"></i>
        <span class="toast-text"></span>
    </div>
    <script type="text/javascript">
        function mostrarToast(mensaje) {
            var toast = document.getElementById('toastCarrito');
            if (!toast) return;
            toast.querySelector('.toast-text').textContent = mensaje;
            toast.classList.add('show');
            clearTimeout(toast._timer);
            toast._timer = setTimeout(function () {
                toast.classList.remove('show');
            }, 2200);
        }
    </script>

    <asp:UpdatePanel runat="server">
        <ContentTemplate>
            <div class="row g-4">
                <div class="col-md-6">
                    <div class="panel" style="padding: 1.25rem;">
                        <h2 style="font-size: 16px; margin: 0 0 1rem;">Marcas</h2>

                        <div class="d-flex gap-2 mb-3">
                            <asp:TextBox ID="txtNuevaMarca" runat="server" CssClass="form-control" placeholder="Nueva marca..." MaxLength="50" />
                            <asp:Button ID="btnAgregarMarca" runat="server" Text="+ Agregar" OnClick="btnAgregarMarca_Click" CssClass="btn-primary" CausesValidation="false" />
                        </div>

                        <asp:Repeater ID="repMarcas" runat="server" OnItemCommand="repMarcas_ItemCommand">
                            <ItemTemplate>
                                <div class="admin-list-row">
                                    <asp:TextBox runat="server" ID="txtDescripcionMarca" Text='<%#Eval("Descripcion")%>' CssClass="form-control" MaxLength="50" />
                                    <asp:Button runat="server" Text="Guardar" CommandName="Guardar" CommandArgument='<%#Eval("Id")%>' CssClass="btn-outline" CausesValidation="false" />
                                    <asp:Button runat="server" Text="Eliminar" CssClass="btn-danger-soft" CausesValidation="false"
                                        UseSubmitBehavior="false"
                                        OnClientClick='<%# "return mostrarModalEliminar(event, " + Eval("Id") + ", 0);" %>' />
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>

                <div class="col-md-6">
                    <div class="panel" style="padding: 1.25rem;">
                        <h2 style="font-size: 16px; margin: 0 0 1rem;">Categorías</h2>
                        <div class="d-flex gap-2 mb-3">
                            <asp:TextBox ID="txtNuevaCategoria" runat="server" CssClass="form-control" placeholder="Nueva categoría..." MaxLength="50" />
                            <asp:Button ID="btnAgregarCategoria" runat="server" Text="+ Agregar" OnClick="btnAgregarCategoria_Click" CssClass="btn-primary" CausesValidation="false" />
                        </div>

                        <asp:Repeater ID="repCategorias" runat="server" OnItemCommand="repCategorias_ItemCommand">
                            <ItemTemplate>
                                <div class="admin-list-row">
                                    <asp:TextBox runat="server" ID="txtDescripcionCategoria" Text='<%#Eval("Descripcion")%>' CssClass="form-control" MaxLength="50" />
                                    <asp:Button runat="server" Text="Guardar" CommandName="Guardar" CommandArgument='<%#Eval("Id")%>' CssClass="btn-outline" CausesValidation="false" />
                                    <asp:Button runat="server" Text="Eliminar" CssClass="btn-danger-soft" CausesValidation="false"
                                        UseSubmitBehavior="false"
                                        OnClientClick='<%# "return mostrarModalEliminar(event, " + Eval("Id") + ", 1);" %>' />
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>

            </div>

            <!-- Esto lo hizo claude code -->
            <!-- Soporte del modal de confirmacion: el tipo (0=marca, 1=categoria) decide que boton oculto disparar -->
            <asp:HiddenField ID="hdnIdMarcaAEliminar" runat="server" />
            <asp:Button ID="btnEliminarMarcaOculto" runat="server" OnClick="btnEliminarMarcaOculto_Click" Style="display: none;" CausesValidation="false" />
            <asp:HiddenField ID="hdnIdCategoriaAEliminar" runat="server" />
            <asp:Button ID="btnEliminarCategoriaOculto" runat="server" OnClick="btnEliminarCategoriaOculto_Click" Style="display: none;" CausesValidation="false" />

            <div id="modalConfirmarEliminar" class="modal-overlay" onclick="cancelarEliminar()">
                <div class="modal-box" onclick="event.stopPropagation()">
                    <p class="modal-text" id="modalEliminarTexto">¿Estás seguro de que querés eliminar este elemento?</p>
                    <div class="modal-actions">
                        <button type="button" class="btn-outline" onclick="cancelarEliminar()">Cancelar</button>
                        <button type="button" class="btn-primary" onclick="confirmarEliminar()">Confirmar</button>
                    </div>
                </div>
            </div>
            <script type="text/javascript">
                var pendienteEliminar = { id: null, tipoCodigo: null };
                function mostrarModalEliminar(evt, id, tipoCodigo) {
                    if (evt) { evt.preventDefault(); evt.stopPropagation(); }
                    pendienteEliminar = { id: id, tipoCodigo: tipoCodigo };
                    document.getElementById('modalEliminarTexto').textContent = tipoCodigo === 0
                        ? '¿Estás seguro de que querés eliminar esta marca?'
                        : '¿Estás seguro de que querés eliminar esta categoría?';
                    document.getElementById('modalConfirmarEliminar').classList.add('show');
                    return false;
                }
                function cancelarEliminar() {
                    pendienteEliminar = { id: null, tipoCodigo: null };
                    document.getElementById('modalConfirmarEliminar').classList.remove('show');
                }
                function confirmarEliminar() {
                    document.getElementById('modalConfirmarEliminar').classList.remove('show');
                    if (pendienteEliminar.tipoCodigo === 0) {
                        document.getElementById('<%= hdnIdMarcaAEliminar.ClientID %>').value = pendienteEliminar.id;
                        document.getElementById('<%= btnEliminarMarcaOculto.ClientID %>').click();
                    } else if (pendienteEliminar.tipoCodigo === 1) {
                        document.getElementById('<%= hdnIdCategoriaAEliminar.ClientID %>').value = pendienteEliminar.id;
                        document.getElementById('<%= btnEliminarCategoriaOculto.ClientID %>').click();
                    }
                }
            </script>

        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
