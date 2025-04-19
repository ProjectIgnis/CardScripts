--Ｓｐ－スピード・フュージョン
--Speed Spell - Speed Fusion
--rescripted by Naim (to match the Fusion Summon Procedure)
local s,id=GetID()
function s.initial_effect(c)
	local e1=Fusion.CreateSummonEff(c)
	e1:SetCondition(s.condition)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
	return tc and tc:GetCounter(0x91)>1
end