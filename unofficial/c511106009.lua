--D－フュージョン
--D-Fusion (Anime)
--original script by Hatter, rescripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsSetCard,SET_DESTINY_HERO),Fusion.OnFieldMat,nil,nil,nil,s.stage2)
	e1:SetCondition(s.condition)
	c:RegisterEffect(e1)
end
s.listed_series={0xc008}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsTurnPlayer(tp)
end
function s.stage2(e,tc,tp,sg,chk)
	if chk==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		tc:RegisterEffect(e2)
	end
end