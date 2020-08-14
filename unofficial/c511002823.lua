--Ancient Gear Scrap Fusion
--rescripted by Naim to match the Fusion Summon procedure
local s,id=GetID()
function s.initial_effect(c)
	local e1=Fusion.CreateSummonEff({handler=c,fusfilter=aux.FilterBoolFunction(Card.IsSetCard,0x7),matfilter=aux.FALSE,extrafil=s.extrafilter,stage2=s.stage2})
	c:RegisterEffect(e1)
end
function s.filter1(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and (not e or not c:IsImmuneToEffect(e))
end
function s.extrafilter(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,0,nil,e)
end
function s.stage2(e,tc,tp,sg,chk)
	if chk==1 and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		Duel.SpecialSummonComplete()
		tc:CompleteProcedure()
	end
end