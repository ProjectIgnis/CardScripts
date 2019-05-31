--Masked Doll
--GameMaster(GM)
local s,id=GetID()
function s.initial_effect(c)
--Activate
local e1=Effect.CreateEffect(c)
e1:SetType(EFFECT_TYPE_ACTIVATE)
e1:SetCode(EVENT_FREE_CHAIN)
c:RegisterEffect(e1)
--Cost Change
local e2=Effect.CreateEffect(c)
e2:SetType(EFFECT_TYPE_FIELD)
e2:SetCode(EFFECT_LPCOST_CHANGE)
e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
e2:SetRange(LOCATION_SZONE)
e2:SetTargetRange(1,0)
e2:SetValue(s.costchange)
c:RegisterEffect(e2)
end
s.listed_names={82432018}
function s.costchange(e,re,rp,val)
if re:GetHandler():IsCode(82432018) then
return 0
else return val end
end