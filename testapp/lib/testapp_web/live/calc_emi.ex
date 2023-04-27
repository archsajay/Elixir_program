defmodule TestappWeb.CalculateEmi do
  require Logger
  use Phoenix.LiveView, layout: {TestappWeb.LayoutView, "live.html"}
  def mount(_params,_session,socket) do
      {:ok,assign(socket, rate: "1.00", principal: "1", tenor: "1", emi: "0")}
  end
  def handle_event("update-rate",%{"value" => value},socket) do
      {:noreply, socket|>assign(rate: value)|>calc_emi} 
  end
  def handle_event("update-principal",%{"value" => value},socket) do
      {:noreply, socket|>assign(principal: value)|>calc_emi}
  end
  def handle_event("update-tenor",%{"value" => value},socket) do
      {:noreply, socket|>assign(tenor: value)|>calc_emi}
  end
 
  def handle_event("update-emi", %{"value" => value},socket) do
      Logger.info("emi is set to " <> socket.assigns.emi)
      {:noreply, socket|>assign(emi: value)}
  end
  defp calc_emi(socket) do
     #calculate months
     Logger.info("Tenor is set to " <> socket.assigns.tenor) 
     months = String.to_integer(socket.assigns.tenor)*12
     Logger.info("Month is set to " <> Integer.to_string(months))      
     #calculate the rate per month
     rate = socket.assigns.rate|>Float.parse|>fetch_rate(socket.assigns.rate)
     rate = rate/1200
     rate_inc = rate+1
     months_dec = months-1
     # calculate the numerator
     exp_num = Float.pow(rate_inc,months)
     numerator = String.to_integer(socket.assigns.principal)*rate*exp_num
     Logger.info("Numerator is set to " <> Float.to_string(numerator))
     denominator = exp_num - 1 
     Logger.info("Denominator is set to " <> Float.to_string(denominator))
     emi = Float.round(numerator/denominator,2)
     Logger.info("Emi is set to " <> Float.to_string(emi))
     assign(socket, emi: emi)
  end

  defp fetch_rate(:error,rate) do
     String.to_integer(rate)
  end
 
  defp fetch_rate({rate,_}, _) do
     rate
  end

  def render(assigns) do
      ~H"""
       <div>
       <label>Rate</label>
       <input type="range" phx-hook="RateSlider" value={"#{@rate}"} min="1" max="10" step="0.05" id="Rate" name="Rate">
       <label>Rate is <%= @rate %></label>
       <label>Principal</label>
       <input type="range" phx-hook="PrincipalSlider"  value={"#{@principal}"} min="1" max="10000000" step="100" id="Principal" name="Principal">
       <label>Principal is <%= @principal %></label>
       <label>Tenor</label>
       <input type="range" phx-hook="TenorSlider" value={"#{@tenor}"} min="1" max="20" step="1" id="Tenor" name="Tenor">
       <label>Tenor is <%= @tenor %></label>
       <label>EMI is </label>
       <input type="text"  name="emi" value={"#{@emi}"}>  
       </div>
       """
  end
end
