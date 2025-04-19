--Frontline Fusion
--rescripted by Naim (to match the Fusion Summon Procedure)
local s,id=GetID()
function s.initial_effect(c)
	local e1=Fusion.CreateSummonEff(c)
	e1:SetCondition(s.condition)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(tp) and Duel.IsBattlePhase()
end