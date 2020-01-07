--Yamadron (DOR)
--scripted by GameMaster (GM)
local s,id=GetID()
function s.initial_effect(c)
c:EnableReviveLimit()
--Flip destroy field cards
local e0=Effect.CreateEffect(c)
e0:SetCategory(CATEGORY_DESTROY)
e0:SetProperty(EFFECT_FLAG_CARD_TARGET)
e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
e0:SetOperation(s.operation)
c:RegisterEffect(e0)
--turn field back to normal/no field spells-destroy
local e1=Effect.CreateEffect(c)
e1:SetCategory(CATEGORY_ANNOUNCE+CATEGORY_DESTROY)
e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
e1:SetCode(EVENT_BATTLE_CONFIRM)
e1:SetOperation(s.operation)
c:RegisterEffect(e1)
end

function s.filter(c) return c:GetSequence()==5 end


function s.operation(e,tp,eg,ep,ev,re,r,rp)
local sg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_SZONE,LOCATION_SZONE,e:GetHandler())
Duel.Destroy(sg,REASON_EFFECT)
end
