--地獄の番熊
local s,id=GetID()
function s.initial_effect(c)
	--indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_SZONE,0)
	e1:SetTarget(s.indtg)
	e1:SetValue(s.indval)
	c:RegisterEffect(e1)
end
s.listed_names={94585852}
function s.indtg(e,c)
	return c:IsFaceup() and c:IsCode(94585852)
end
function s.indval(e,re,tp)
	return e:GetHandler():GetControler()~=tp
end
