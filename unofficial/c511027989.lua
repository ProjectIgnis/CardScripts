--生存本能 (Anime)
---Survival Instinct (Anime)
--Made by When
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_RECOVER)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end
function s.cfilter(c)
    return c:IsRace(RACE_DINOSAUR) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost() and c:IsLocation(LOCATION_HAND)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND,0,nil)
    if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local cg=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,#g,nil)
    Duel.Remove(cg,POS_FACEUP,REASON_COST)
    e:SetLabel(#cg*400)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(e:GetLabel())
    Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,e:GetLabel())
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Recover(p,d,REASON_EFFECT)
end