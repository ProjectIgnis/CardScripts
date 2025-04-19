--絶望神アンチホープ
--Dystopia the Despondent
local s,id=GetID()
function s.initial_effect(c)
	--Your opponent cannot Xyz Summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetTarget(function(_,_,_,sumtp) return (sumtp&SUMMON_TYPE_XYZ)==SUMMON_TYPE_XYZ end)
	c:RegisterEffect(e1)
end