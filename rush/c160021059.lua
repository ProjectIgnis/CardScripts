--英雄の降臨
--Legend Advent
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Treated as a Legend Card in the GY
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_IS_LEGEND)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_GRAVE)
	c:RegisterEffect(e0)
	--Ritual Summon
	local e1=Ritual.CreateProc({handler=c,lvtype=RITPROC_GREATER,filter=s.ritualfil,matfilter=s.forcedgroup})
	c:RegisterEffect(e1)
end
s.listed_names={160021049}
function s.ritualfil(c)
	return c:IsCode(160021049)
end
function s.forcedgroup(c,e,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup()
end