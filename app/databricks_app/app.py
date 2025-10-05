import matplotlib.pyplot as plt
from IPython.display import display, Markdown, Image
import ipywidgets as widgets
from embeddings import query_pgvector
from analytics import get_financial_summary

def gerar_relatorio(prompt, ticker):
    ri_textos = query_pgvector(prompt)
    dados = get_financial_summary(ticker)

    relatorio = f"""
📊 **Relatório Analítico – {ticker}**

- Receita líquida: R$ {dados['receita']:.2f} bilhões
- Lucro líquido: R$ {dados['lucro']:.2f} bilhões
- EBITDA ajustado: R$ {dados['ebitda']:.2f} bilhões

📄 **Insights dos relatórios de RI**:
"""
    for texto in ri_textos:
        relatorio += f"- {texto[:200].strip()}...\n"

    return relatorio

def gerar_dashboard(ticker):
    dados = get_financial_summary(ticker)
    labels = ["Receita", "Lucro", "EBITDA"]
    valores = [dados["receita"], dados["lucro"], dados["ebitda"]]

    plt.figure(figsize=(8, 5))
    plt.bar(labels, valores, color=["#1f77b4", "#ff7f0e", "#2ca02c"])
    plt.title(f"Indicadores Financeiros – {ticker}")
    plt.ylabel("R$ bilhões")
    plt.grid(axis="y", linestyle="--", alpha=0.6)
    plt.tight_layout()
    plt.savefig(f"{ticker}_dashboard.png")
    plt.close()

def iniciar_app():
    # Interface interativa
    acoes = ["PETR4", "VALE3", "ITUB4", "BBDC4", "ABEV3"]
    dropdown = widgets.Dropdown(options=acoes, description="Ação:")
    prompt_input = widgets.Text(
        value="Resumo dos principais indicadores e eventos da empresa",
        description="Pergunta:",
        layout=widgets.Layout(width="80%")
    )
    botao = widgets.Button(description="Gerar Relatório")
    output = widgets.Output()

    display(dropdown, prompt_input, botao, output)

    def on_click(b):
        output.clear_output()
        with output:
            ticker = dropdown.value
            prompt = prompt_input.value + f" ({ticker})"
            relatorio = gerar_relatorio(prompt, ticker)
            gerar_dashboard(ticker)
            display(Markdown(relatorio))
            display(Image(filename=f"{ticker}_dashboard.png"))

    botao.on_click(on_click)

# Executa o App
if __name__ == "__main__":
    iniciar_app()

