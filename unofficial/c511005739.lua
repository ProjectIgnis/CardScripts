--BladeFly (DOR)
--scripted by GameMaster (GM)
local s,id=GetID()
function s.initial_effect(c)
--wind monster boost of 600ATK/DEF
local e1=Effect.CreateEffect(c)
e1:SetType(EFFECT_TYPE_FIELD)
e1:SetCode(EFFECT_UPDATE_ATTACK)
e1:SetRange(LOCATION_MZONE)
e1:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_WIND))
e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
e1:SetValue(500)
e1:SetCondition(s.con)
c:RegisterEffect(e1)
local e2=e1:Clone()
e2:SetCode(EFFECT_UPDATE_DEFENSE)
c:RegisterEffect(e2)
end

function s.con(e)
return e:GetHandler():IsDefensePos()
end