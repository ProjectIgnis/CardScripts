--ゼラの降臨
--Zera Advent
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--name change
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CHANGE_CODE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_GRAVE)
	e0:SetValue(81756897)
	c:RegisterEffect(e0)
	local e1=Ritual.CreateProc({handler=c,lvtype=RITPROC_GREATER,filter=s.ritualfil,matfilter=s.forcedgroup})
	c:RegisterEffect(e1)
end
s.listed_names={69123138,160215002}
function s.ritualfil(c)
	return c:IsCode(69123138,160215002)
end
function s.forcedgroup(c,e,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup()
end