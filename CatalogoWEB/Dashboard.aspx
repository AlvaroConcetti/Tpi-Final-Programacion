<%@ Page Title="" Language="C#" MasterPageFile="~/Master.Master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="CatalogoWEB.Dashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <!-- Esto lo hizo claude code ↓ -->
    <div class="page-header">
        <div>
            <h1 class="page-title">Dashboard</h1>
            <p class="page-subtitle">Resumen del negocio de un vistazo</p>
        </div>
        <div class="d-flex align-items-center gap-2">
            <asp:Label Text="Período" runat="server" CssClass="form-label mb-0" />
            <asp:DropDownList runat="server" ID="ddlRango" CssClass="form-select"
                AutoPostBack="true" OnSelectedIndexChanged="ddlRango_SelectedIndexChanged">
                <asp:ListItem Text="Últimos 7 días" Value="7" />
                <asp:ListItem Text="Últimos 30 días" Value="30" Selected="True" />
                <asp:ListItem Text="Últimos 90 días" Value="90" />
                <asp:ListItem Text="Todo el historial" Value="0" />
            </asp:DropDownList>
        </div>
    </div>

    <!-- KPIs -->
    <div class="row g-3 mb-4">
        <div class="col-6 col-lg-3">
            <div class="panel kpi-card">
                <span class="kpi-label"><i class="bi bi-cash-stack me-1"></i>Ventas del período</span>
                <span class="kpi-value">$<%= Kpis.TotalVentas.ToString("N2") %></span>
                <span class="kpi-detail"><%= Kpis.UnidadesVendidas %> unidades vendidas</span>
            </div>
        </div>
        <div class="col-6 col-lg-3">
            <div class="panel kpi-card">
                <span class="kpi-label"><i class="bi bi-receipt me-1"></i>Ventas confirmadas</span>
                <span class="kpi-value"><%= Kpis.CantidadVentas %></span>
                <span class="kpi-detail"><%= Kpis.PedidosCancelados %> pedidos cancelados</span>
            </div>
        </div>
        <div class="col-6 col-lg-3">
            <div class="panel kpi-card">
                <span class="kpi-label"><i class="bi bi-graph-up-arrow me-1"></i>Ticket promedio</span>
                <span class="kpi-value">$<%= Kpis.TicketPromedio.ToString("N2") %></span>
                <span class="kpi-detail">por venta confirmada</span>
            </div>
        </div>
        <div class="col-6 col-lg-3">
            <div class="panel kpi-card <%= Kpis.PedidosPendientes > 0 ? "kpi-card--alerta" : "" %>">
                <span class="kpi-label"><i class="bi bi-hourglass-split me-1"></i>Pedidos pendientes</span>
                <span class="kpi-value"><%= Kpis.PedidosPendientes %></span>
                <span class="kpi-detail">esperando confirmación</span>
            </div>
        </div>
    </div>

    <!-- Ventas por dia + por categoria -->
    <div class="row g-3 mb-4">
        <div class="col-lg-8">
            <div class="panel dashboard-panel">
                <h2 class="dashboard-panel-title">Ventas por día</h2>
                <div class="dashboard-chart-wrap">
                    <canvas id="chartVentasPorDia"></canvas>
                    <p class="dashboard-empty" id="emptyVentasPorDia" style="display: none;">Sin ventas en el período seleccionado.</p>
                </div>
            </div>
        </div>
        <div class="col-lg-4">
            <div class="panel dashboard-panel">
                <h2 class="dashboard-panel-title">Ventas por categoría</h2>
                <div class="dashboard-chart-wrap">
                    <canvas id="chartCategorias"></canvas>
                    <p class="dashboard-empty" id="emptyCategorias" style="display: none;">Sin ventas en el período seleccionado.</p>
                </div>
            </div>
        </div>
    </div>

    <!-- Top vendidos + stock bajo + favoritos -->
    <div class="row g-3">
        <div class="col-lg-5">
            <div class="panel dashboard-panel">
                <h2 class="dashboard-panel-title">Top 5 más vendidos</h2>
                <div class="dashboard-chart-wrap">
                    <canvas id="chartTopArticulos"></canvas>
                    <p class="dashboard-empty" id="emptyTopArticulos" style="display: none;">Sin ventas en el período seleccionado.</p>
                </div>
            </div>
        </div>
        <div class="col-lg-4">
            <div class="panel dashboard-panel">
                <h2 class="dashboard-panel-title">⚠️ Stock bajo (5 o menos)</h2>
                <asp:Repeater runat="server" ID="repStockBajo">
                    <ItemTemplate>
                        <div class="dashboard-list-row">
                            <span class="dashboard-list-nombre"><%# Eval("Nombre") %> <span class="dashboard-list-codigo">(<%# Eval("Codigo") %>)</span></span>
                            <span class='<%# (int)Eval("Stock") == 0 ? "dashboard-stock dashboard-stock--cero" : "dashboard-stock" %>'>
                                <%# (int)Eval("Stock") == 0 ? "Sin stock" : Eval("Stock") + " u." %>
                            </span>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
                <asp:Label runat="server" ID="lblSinStockBajo" Visible="false"
                    Text="Todo el catálogo tiene stock suficiente. ✅" CssClass="dashboard-empty" />
            </div>
        </div>
        <div class="col-lg-3">
            <div class="panel dashboard-panel">
                <h2 class="dashboard-panel-title">❤️ Más favoriteados</h2>
                <asp:Repeater runat="server" ID="repFavoritos">
                    <ItemTemplate>
                        <div class="dashboard-list-row">
                            <span class="dashboard-list-nombre"><%# Eval("Nombre") %></span>
                            <span class="dashboard-stock"><%# Eval("Cantidad") %></span>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
                <asp:Label runat="server" ID="lblSinFavoritos" Visible="false"
                    Text="Ningún artículo fue marcado como favorito todavía." CssClass="dashboard-empty" />
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
    <script type="text/javascript">
        // Los datos llegan serializados desde el code-behind (JavaScriptSerializer)
        var ventasPorDia = <%= VentasPorDiaJson %>;
        var ventasPorCategoria = <%= CategoriasJson %>;
        var topArticulos = <%= TopArticulosJson %>;

        // Paleta acorde al tema del sitio (tonos calidos + acentos)
        var colores = ['#2f6690', '#2a7d4f', '#c78a2d', '#b83232', '#6a5f8f', '#4a8f8a', '#9a6c4f'];
        var estilos = getComputedStyle(document.documentElement);
        var colorTexto = estilos.getPropertyValue('--text-secondary').trim();
        var colorBorde = estilos.getPropertyValue('--border').trim();

        Chart.defaults.color = colorTexto;
        Chart.defaults.font.family = "'Plus Jakarta Sans', sans-serif";

        function formatoPesos(valor) {
            return '$' + valor.toLocaleString('es-AR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
        }

        // Si no hay datos se muestra el mensaje en lugar de un grafico vacio
        function ocultarSiVacio(datos, canvasId, emptyId) {
            if (datos.length > 0) return false;
            document.getElementById(canvasId).style.display = 'none';
            document.getElementById(emptyId).style.display = 'block';
            return true;
        }

        if (!ocultarSiVacio(ventasPorDia, 'chartVentasPorDia', 'emptyVentasPorDia')) {
            new Chart(document.getElementById('chartVentasPorDia'), {
                type: 'bar',
                data: {
                    labels: ventasPorDia.map(function (v) { return v.Fecha; }),
                    datasets: [{
                        label: 'Ventas',
                        data: ventasPorDia.map(function (v) { return v.Total; }),
                        backgroundColor: '#2f6690',
                        borderRadius: 4
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { display: false },
                        tooltip: { callbacks: { label: function (ctx) { return formatoPesos(ctx.parsed.y); } } }
                    },
                    scales: {
                        x: { grid: { display: false } },
                        y: { grid: { color: colorBorde }, ticks: { callback: function (v) { return formatoPesos(v); } } }
                    }
                }
            });
        }

        if (!ocultarSiVacio(ventasPorCategoria, 'chartCategorias', 'emptyCategorias')) {
            new Chart(document.getElementById('chartCategorias'), {
                type: 'doughnut',
                data: {
                    labels: ventasPorCategoria.map(function (v) { return v.Categoria; }),
                    datasets: [{
                        data: ventasPorCategoria.map(function (v) { return v.Total; }),
                        backgroundColor: colores,
                        borderWidth: 0
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { position: 'bottom' },
                        tooltip: { callbacks: { label: function (ctx) { return ctx.label + ': ' + formatoPesos(ctx.parsed); } } }
                    }
                }
            });
        }

        if (!ocultarSiVacio(topArticulos, 'chartTopArticulos', 'emptyTopArticulos')) {
            new Chart(document.getElementById('chartTopArticulos'), {
                type: 'bar',
                data: {
                    labels: topArticulos.map(function (v) { return v.Nombre; }),
                    datasets: [{
                        label: 'Facturado',
                        data: topArticulos.map(function (v) { return v.Total; }),
                        backgroundColor: colores,
                        borderRadius: 4
                    }]
                },
                options: {
                    indexAxis: 'y',
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { display: false },
                        tooltip: {
                            callbacks: {
                                label: function (ctx) {
                                    var item = topArticulos[ctx.dataIndex];
                                    return formatoPesos(ctx.parsed.x) + ' · ' + item.Unidades + ' u.';
                                }
                            }
                        }
                    },
                    scales: {
                        x: { grid: { color: colorBorde }, ticks: { callback: function (v) { return formatoPesos(v); } } },
                        y: { grid: { display: false } }
                    }
                }
            });
        }
    </script>

</asp:Content>
