--Skull Stalker (DOR)
--scripted by GameMaster (GM)
local s,id=GetID()
function s.initial_effect(c)
-- lose 300 atk/def when destroyed
local e1=Effect.CreateEffect(c)
e1:SetDescription(aux.Stringid(id,1))
e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
e1:SetCode(EVENT_BATTLE_DESTROYED)
e1:SetOperation(s.desop)
c:RegisterEffect(e1)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
local tc=Duel.GetAttacker()
if c==tc then tc=Duel.GetAttackTarget() end
if not tc:IsRelateToBattle() then return end
local e1=Effect.CreateEffect(c)
e1:SetType(EFFECT_TYPE_SINGLE)
e1:SetCode(EFFECT_UPDATE_ATTACK)
e1:SetReset(RESET_EVENT+RESETS_STANDARD)
e1:SetValue(-300)
tc:RegisterEffect(e1)
local e2=e1:Clone()
e2:SetCode(EFFECT_UPDATE_DEFENSE)
tc:RegisterEffect(e2)
end


