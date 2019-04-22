--Hexa Knight
local s,id=GetID()
function s.initial_effect(c)
    --summon
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(95100665,0))
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_SUMMON_PROC)
    e2:SetCondition(s.ntcon)
    c:RegisterEffect(e2)
end
function s.ntcon(e,c)
	if c==nil then return true end
	return c:GetLevel()>4
		and Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)==0
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
