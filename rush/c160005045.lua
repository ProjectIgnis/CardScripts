-- 監獄島アネ・ゴ ・ロック
--Prison Island - Cell Block 5 & 6
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--cannot tribute summon
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	e2:SetTarget(s.sumlimit)
	e2:SetTargetRange(1,1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_MSET)
	c:RegisterEffect(e3)
end

function s.sumlimit(e,c,tp,sumtp)
	return sumtp&SUMMON_TYPE_TRIBUTE==SUMMON_TYPE_TRIBUTE and (c:IsLevel(5) or c:IsLevel(6))
end
