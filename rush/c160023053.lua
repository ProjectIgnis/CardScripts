--ハイパースピード
--Hyper Speed
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	Fusion.RegisterSummonEff(c,s.fusfilter,s.matfilter,nil,nil,nil,s.stage2)
end
function s.fusfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsLevel(4) and c:IsDefense(800)
end
function s.matfilter(c)
	return c:IsLocation(LOCATION_HAND|LOCATION_MZONE) and c:IsAbleToGrave()
end
function s.stage2(e,tc,tp,mg,chk)
	if chk==0 then
		if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,160023056) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_PHASE|PHASE_END)
			e1:SetValue(600)
			tc:RegisterEffect(e1)
		end
	end
end