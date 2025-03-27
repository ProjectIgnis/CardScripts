--Ｄ－フュージョン
--D-Fusion
local s,id=GetID()
function s.initial_effect(c)
	--Fusion summon 1 "Destiny HERO" fusion monster
	--Using monsters you control as fusion material
	c:RegisterEffect(Fusion.CreateSummonEff(c,nil,Fusion.OnFieldMat(aux.FilterBoolFunction(Card.IsSetCard,SET_DESTINY_HERO)),nil,nil,nil,s.stage2))
end
s.listed_series={SET_DESTINY_HERO}
function s.stage2(e,tc,tp,sg,chk)
	if chk==0 then
		--Cannot be destroyed by battle or card effect
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3008)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		tc:RegisterEffect(e2)
	end
end