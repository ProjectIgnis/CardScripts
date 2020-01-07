--Mirror wall (DOR)
--scripted by GameMaster(GM)
local s,id=GetID()
function s.initial_effect(c)
--Activate
local e1=Effect.CreateEffect(c)
e1:SetType(EFFECT_TYPE_ACTIVATE)
e1:SetCategory(CATEGORY_ATKCHANGE)
e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
e1:SetCode(EVENT_ATTACK_ANNOUNCE)
e1:SetHintTiming(0,TIMING_DAMAGE_STEP)
e1:SetCondition(s.condition)
e1:SetOperation(s.operation)
e1:SetTargetRange(0,LOCATION_MZONE)
e1:SetTarget(s.tg)
c:RegisterEffect(e1)
--half attacking monster atk/2 each attack
local e2=Effect.CreateEffect(c)
e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
e2:SetCategory(CATEGORY_ATKCHANGE)
e2:SetCode(EVENT_ATTACK_ANNOUNCE)
e2:SetRange(LOCATION_SZONE)
e2:SetTargetRange(0,LOCATION_MZONE)
e2:SetOperation(s.operation)
e2:SetTarget(s.tg)
c:RegisterEffect(e2)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()   
local at=Duel.GetAttacker() 
if not at or Duel.GetTurnPlayer()==tp then return false end
if at and at:IsControler(1-tp) and at:IsFaceup() and at:IsLocation(LOCATION_MZONE) then
return at and Duel.GetTurnPlayer()~=tp and at:IsRelateToBattle() 
end
end

function s.filter(c)
return c:GetAttacker()
end

function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
if chk==0 then return Duel.GetTurnPlayer()~=tp end
local g=Group.FromCards(Duel.GetAttacker(),Duel.GetAttacker())
Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,0,0)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
local tc=Duel.GetAttacker()
local VAL=tc:GetAttack()/2
while tc do
--atkchange
local e3=Effect.CreateEffect(e:GetHandler())
e3:SetType(EFFECT_TYPE_SINGLE)
e3:SetCategory(CATEGORY_ATKCHANGE)
e3:SetProperty(EFFECT_FLAG_COPY_INHERIT+EFFECT_FLAG_CANNOT_DISABLE)
e3:SetCode(EFFECT_UPDATE_ATTACK)
e3:SetValue(-VAL)
e3:SetReset(RESET_EVENT+RESETS_STANDARD)
tc:RegisterEffect(e3)
tc=nil
end
end

