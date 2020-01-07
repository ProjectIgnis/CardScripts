--Hiros shadow scout DOR
--scripted by GameMaster(GM)
local s,id=GetID()
function s.initial_effect(c)
--flip opponents facedown cards
local e1=Effect.CreateEffect(c)
e1:SetCategory(CATEGORY_FLIP)
e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
e1:SetOperation(s.op)
c:RegisterEffect(e1)
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
local conf=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD,POS_FACEDOWN)
if #conf>0 then
Duel.ConfirmCards(tp,conf)
end
end
