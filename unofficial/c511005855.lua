--Gate Guardian (DOR)
--scripted by GameMaster(GM)
local s,id=GetID()
function s.initial_effect(c)
c:EnableReviveLimit()
--battle dam 0
local e1=Effect.CreateEffect(c)
e1:SetType(EFFECT_TYPE_SINGLE)
e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
e1:SetValue(1)
c:RegisterEffect(e1)
end