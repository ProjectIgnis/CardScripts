--Copycat (DOR)
--scripted by GameMaster (GM)
local s,id=GetID()
function s.initial_effect(c)
--Activate
local e1=Effect.CreateEffect(c)
e1:SetType(EFFECT_TYPE_ACTIVATE)
e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
e1:SetCode(EVENT_FREE_CHAIN)
e1:SetTarget(s.tg)
e1:SetOperation(s.activate)
c:RegisterEffect(e1)
end

function s.filter(c)
return c:IsType(TYPE_SPELL+TYPE_TRAP) 
end

function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
if chk==0 then return ft>0 and Duel.IsExistingTarget(s.filter,tp,0,LOCATION_GRAVE,1,nil) end
Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_GRAVE,1,1,nil)
Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
local tc=Duel.GetFirstTarget()
if tc:IsRelateToEffect(e) then
Duel.SSet(tp,tc)
end
end
