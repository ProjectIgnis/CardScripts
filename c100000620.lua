--新生代化石マシン　スカルバギー
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,s.ffilter1,s.ffilter2)
	--cannot spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetValue(s.splimit)
	c:RegisterEffect(e2)
end
s.listed_names={100000025}
function s.splimit(e,se,sp,st)
	return st&SUMMON_TYPE_FUSION~=SUMMON_TYPE_FUSION or se:GetHandler():IsCode(100000025)
end
function s.ffilter1(c,fc,sumtype,tp)
	return c:IsRace(RACE_ROCK,fc,sumtype,tp) and c:IsLocation(LOCATION_GRAVE) and c:IsControler(tp)
end
function s.ffilter2(c,fc,sumtype,tp)
	return c:IsType(TYPE_MONSTER,fc,sumtype,tp) and c:IsLocation(LOCATION_GRAVE) and c:IsControler(1-tp)
end
