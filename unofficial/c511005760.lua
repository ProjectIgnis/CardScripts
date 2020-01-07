--Gale Dogra (DOR)
--scripted by GameMaster (GM)
local s,id=GetID()
function s.initial_effect(c)
--atkdown
local e3=Effect.CreateEffect(c)
e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_TRIGGER_F)
e3:SetCode(EVENT_PREDRAW)
e3:SetRange(LOCATION_MZONE)
e3:SetCondition(s.atkcon)
e3:SetOperation(s.atkop)
e3:SetCountLimit(1)
c:RegisterEffect(e3)
end

function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
return Duel.GetTurnPlayer()==tp and e:GetHandler():IsDefensePos()
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
local g=Duel.GetMatchingGroup(Card.IsOnfield,tp,0,LOCATION_MZONE,nil)
local tc=g:GetFirst()
while tc do
local e1=Effect.CreateEffect(e:GetHandler())
e1:SetType(EFFECT_TYPE_SINGLE)
e1:SetCode(EFFECT_UPDATE_ATTACK)
e1:SetValue(-100)
e1:SetReset(RESET_EVENT+RESETS_STANDARD)
tc:RegisterEffect(e1)
local e2=e1:Clone()
e2:SetCode(EFFECT_UPDATE_DEFENSE)
tc:RegisterEffect(e2)
tc=g:GetNext()
end
end
