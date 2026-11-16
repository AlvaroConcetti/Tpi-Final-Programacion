<%@ Page Title="" Language="C#" MasterPageFile="~/Master.Master" AutoEventWireup="true" CodeBehind="Administracion.aspx.cs" Inherits="CatalogoWEB.Administracion" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <asp:ScriptManager runat="server" />

    <div class="page-header">
        <div>
            <h1 class="page-title">Artículos</h1>
            <p class="page-subtitle">Gestioná los artículos del catálogo</p>
        </div>
        <div class="page-actions">
            <asp:Button ID="btnAgregarArticulo" Text="Agregar artículo" runat="server"
                OnClick="btnAgregarArticulo_Click" CssClass="btn-primary" />
        </div>
    </div>

    <asp:UpdatePanel runat="server">
        <ContentTemplate>

            <!-- Barra de busqueda rapida -->
            <div class="admin-search">
                <div class="search-pill">
                    <i class="bi bi-search"></i>
                    <asp:TextBox ID="txtBoxFiltrar" runat="server" CssClass="form-control"
                        placeholder="Buscar por nombre" AutoPostBack="true"
                        OnTextChanged="txtBoxFiltrar_TextChanged" MaxLength="20" />
                </div>
                <asp:Button ID="btnBorrarFiltro" Text="Limpiar" runat="server"
                    OnClick="btnBorrarFiltro_Click" CssClass="btn-ghost" />
            </div>

            <!-- Filtro avanzado -->
            <div class="filter-bar mb-4">
                <div class="row g-3 align-items-end">
                    <div class="col-auto">
                        <asp:Label Text="Filtrar por" runat="server" ID="lblDdlFiltrar" CssClass="form-label" />
                        <asp:DropDownList runat="server" ID="ddlFiltrar" CssClass="form-select"
                            OnSelectedIndexChanged="ddlFiltrar_SelectedIndexChanged" AutoPostBack="true">
                            <asp:ListItem Text="Código" />
                            <asp:ListItem Text="Precio" />
                            <asp:ListItem Text="Marca" />
                            <asp:ListItem Text="Categoría" />
                        </asp:DropDownList>
                    </div>
                    <div class="col-auto">
                        <asp:Label Text="Criterio" runat="server" ID="lblDdlCriterio" CssClass="form-label" />
                        <asp:DropDownList runat="server" ID="ddlCriterio" CssClass="form-select" AutoPostBack="true" />
                    </div>
                    <div class="col-auto">
                        <asp:Label Text="" runat="server" ID="lblTxtBoxFiltrarAvanzado" Visible="true" CssClass="form-label" />
                        <asp:TextBox runat="server" ID="txtBoxFiltrarAvanzado" Visible="true" CssClass="form-control" />
                    </div>

                    <div class="col-auto d-flex gap-2">
                        <asp:Button ID="btnFiltrar" Text="Aplicar" runat="server"
                            OnClick="btnFiltrar_Click" CssClass="btn-primary" />
                        <asp:Button ID="btnLimpiarFiltroAvanzado" Text="Limpiar" runat="server"
                            OnClick="btnLimpiarFiltroAvanzado_Click" CssClass="btn-outline" />
                    </div>
                </div>
            </div>

            <!-- Tabla de articulos -->
            <div class="panel">
                <div class="panel-scroll">
                    <asp:GridView runat="server" ID="dgvArticulos" CssClass="table"
                        AutoGenerateColumns="false"
                        OnRowCommand="dgvArticulos_RowCommand"
                        OnRowDataBound="dgvArticulos_RowDataBound"
                        OnPageIndexChanging="dgvArticulos_PageIndexChanging"
                        AllowPaging="true" PageSize="5"
                        PagerStyle-CssClass="gridview-pager"
                        PagerStyle-HorizontalAlign="Center">
                        <%-- El orden de las columnas importa: el code-behind lee Cells[0] (Id), Cells[5] (Stock) y Cells[7] (Eliminar) --%>
                        <Columns>
                            <asp:BoundField HeaderText="Id" DataField="Id" HeaderStyle-CssClass="oculto" ItemStyle-CssClass="oculto" />
                            <asp:TemplateField HeaderText="Artículo">
                                <ItemTemplate>
                                    <div class="grid-product">
                                        <span class="grid-thumb">
                                            <img src='<%#: Eval("UrlImagen") %>' alt="" loading="lazy" onerror="this.style.visibility='hidden'" />
                                        </span>
                                        <span class="grid-product-text">
                                            <span class="grid-product-name"><%#: Eval("Nombre") %></span>
                                            <span class="grid-product-code"><%#: Eval("Codigo") %></span>
                                        </span>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField HeaderText="Categoría" DataField="Categoria" />
                            <asp:BoundField HeaderText="Marca" DataField="Marca" />
                            <asp:BoundField HeaderText="Precio" DataField="Precio" DataFormatString="${0:N2}" ItemStyle-CssClass="grid-num" />
                            <asp:BoundField HeaderText="Stock" DataField="Stock" />
                            <asp:ButtonField HeaderText="" CommandName="Editar" Text="Editar" ControlStyle-CssClass="btn-select" ItemStyle-CssClass="grid-action" />
                            <asp:ButtonField HeaderText="" CommandName="Eliminar" Text="Eliminar" ControlStyle-CssClass="btn-select btn-select--danger" ItemStyle-CssClass="grid-action" />
                        </Columns>
                    </asp:GridView>
                </div>
            </div>

            <!-- Esto lo hizo claude code ↓ -->
            <!-- Modal de confirmacion para "Eliminar" -->
            <div id="modalConfirmarEliminarArticulo" class="modal-overlay" onclick="cancelarEliminarArticulo()">
                <div class="modal-box" onclick="event.stopPropagation()">
                    <p class="modal-text">¿Estás seguro de que querés eliminar este artículo? Esta acción no se puede deshacer.</p>
                    <div class="modal-actions">
                        <button type="button" class="btn-outline" onclick="cancelarEliminarArticulo()">Cancelar</button>
                        <button type="button" class="btn-primary" onclick="confirmarEliminarArticulo()">Confirmar</button>
                    </div>
                </div>
            </div>
            <script type="text/javascript">
                var elementoAEliminarArticulo = null;
                function mostrarModalEliminarArticulo(evt, elemento) {
                    if (evt) { evt.preventDefault(); evt.stopPropagation(); }
                    elementoAEliminarArticulo = elemento;
                    document.getElementById('modalConfirmarEliminarArticulo').classList.add('show');
                    return false;
                }
                function cancelarEliminarArticulo() {
                    elementoAEliminarArticulo = null;
                    document.getElementById('modalConfirmarEliminarArticulo').classList.remove('show');
                }
                function confirmarEliminarArticulo() {
                    document.getElementById('modalConfirmarEliminarArticulo').classList.remove('show');
                    if (elementoAEliminarArticulo) {
                        elementoAEliminarArticulo.onclick = null;
                        elementoAEliminarArticulo.click();
                    }
                }
            </script>

        </ContentTemplate>
    </asp:UpdatePanel>

</asp:Content>
