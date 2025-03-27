--ビークロイド・コネクション・ゾーン
--Vehicroid Connection Zone
local s,id=GetID()
function s.initial_effect(c)
	--Fusion summon 1 "Vehicroid" fusion monster
	--Using monsters from hand or field as fusion material
	c:RegisterEffect(Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsSetCard,SET_VEHICROID),nil,nil,nil,nil,s.stage2))
end
s.listed_series={SET_VEHICROID}
function s.stage2(e,tc,tp,sg,chk)
	if chk==1 then
		local c=e:GetHandler()
		--Cannot be destroyed by card effects
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3001)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		--Cannot be negated
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(3308)
		e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_CANNOT_DISEFFECT)
		e3:SetRange(LOCATION_MZONE)
		e3:SetValue(s.efilter)
		e3:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e3,true)
	end
end
function s.efilter(e,ct)
	local te=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT)
	return te:GetHandler()==e:GetHandler()
end