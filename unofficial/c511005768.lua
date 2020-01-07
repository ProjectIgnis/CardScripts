--Change of Heart (DOR)
--scripted by GameMaster (GM)
local s,id=GetID()
function s.initial_effect(c)
--Take Control 1 card till end-phase
local e1=Effect.CreateEffect(c)
e1:SetDescription(aux.Stringid(id,0))
e1:SetCategory(CATEGORY_CONTROL)
e1:SetType(EFFECT_TYPE_ACTIVATE)
e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
e1:SetCode(EVENT_FREE_CHAIN)
e1:SetTarget(s.target1)
e1:SetOperation(s.activate1)
c:RegisterEffect(e1)
end

function s.filter(c,e)
return c:IsType(0xff)  and c:IsAbleToChangeControler() and not c:IsImmuneToEffect(e) 
end

function s.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
if chkc then return chkc:IsOnField() and s.filter(chkc) and chkc~=e:GetHandler() end
if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_ONFIELD,1,e:GetHandler(),e) 
and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_ONFIELD,1,1,e:GetHandler(),e)
Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end

function s.activate1(e,tp,eg,ep,ev,re,r,rp)
local tc=Duel.GetFirstTarget()
if tc and tc:IsRelateToEffect(e) then
if tc:IsType(TYPE_SPELL+TYPE_TRAP) then
local e1=Effect.CreateEffect(e:GetHandler())
e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
e1:SetCode(EVENT_PHASE+PHASE_END)
e1:SetCountLimit(1)
e1:SetReset(RESET_PHASE+PHASE_END)
e1:SetLabelObject(tc)
e1:SetOperation(s.retop)
Duel.RegisterEffect(e1,tp)
local pos=tc:GetPosition()	
Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,pos,true)
else  if tc:IsType(TYPE_MONSTER) then  
Duel.GetControl(tc,tp,PHASE_END,1)
end
end
end
end 

function s.retop(e,tp,eg,ep,ev,re,r,rp)
local tc=e:GetLabelObject()
if tc and tc:IsLocation(LOCATION_ONFIELD) and tc:IsControler(tp) then
if tc:IsFacedown() then 
Duel.MoveToField(tc,1-tp,1-tp,LOCATION_SZONE,POS_FACEDOWN,true)
elseif tc:IsFaceup() then  
Duel.MoveToField(tc,1-tp,1-tp,LOCATION_SZONE,POS_FACEUP,true)
end
end
end

