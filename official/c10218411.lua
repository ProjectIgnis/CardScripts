--二重融合
--Double Fusion
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	local e1=Fusion.CreateSummonEff({handler=c,stage2=s.stage2})
	e1:SetCost(Cost.PayLP(500))
	c:RegisterEffect(e1)
end
function s.stage2(e,tc,tp,sg,chk)
	if chk==1 then
		if Fusion.SummonEffTG()(e,tp,eg,ep,ev,re,r,rp,0) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			Fusion.SummonEffOP()(e,tp,eg,ep,ev,re,r,rp)
		end
	end
end