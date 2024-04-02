--究極の青眼伝説
--The Ultimate Blue-Eyed Legend
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	Fusion.RegisterSummonEff{handler=c,fusfilter=s.ffilter,matfilter=s.matfilter,maxcount=3,stage2=s.stage2}
end
function s.ffilter(c)
	return c:IsLevelAbove(10) and c:IsRace(RACE_DRAGON)
end
function s.matfilter(c)
	return c:IsMonster() and c:IsRace(RACE_DRAGON)
end
function s.stage2(e,tc,tp,sg,chk)
	if chk==0 then
		--Cannot be destroyed by card effects
		local e1=Effect.CreateEffect(tc)
		e1:SetDescription(3001)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		e1:SetValue(function(e,te)return te:GetOwnerPlayer()~=e:GetHandlerPlayer()end)
		tc:RegisterEffect(e1,true)
	end
end