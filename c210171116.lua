--Nekroz Illusion
function c210171116.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,210171116+EFFECT_COUNT_CODE_OATH)
    e1:SetCost(c210171116.cost)
    e1:SetTarget(c210171116.target)
    e1:SetOperation(c210171116.operation)
    c:RegisterEffect(e1)
    --act in set turn
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
    e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    e2:SetCondition(c210171116.actcon)
    c:RegisterEffect(e2)
end
function c210171116.filter(c)
    return c:IsSetCard(0xb4) and c:GetType()==TYPE_SPELL+TYPE_RITUAL and c:CheckActivateEffect(true,true,false)~=nil
		and ((not c:IsPublic() and c:IsLocation(LOCATION_HAND)) or (c:IsAbleToGraveAsCost() and c:IsLocation(LOCATION_DECK)))
end
function c210171116.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    e:SetLabel(1)
    return true
end
function c210171116.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then
        local te=e:GetLabelObject()
        local tg=te:GetTarget()
        return tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
    end
    if chk==0 then
        if e:GetLabel()==0 then return false end
        e:SetLabel(0)
        return Duel.IsExistingMatchingCard(c210171116.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) 
    end
    e:SetLabel(0)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
    local g=Duel.SelectMatchingCard(tp,c210171116.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
    local te=g:GetFirst():CheckActivateEffect(true,true,false)
    e:SetLabelObject(te)
    if g:GetFirst():IsLocation(LOCATION_HAND) then
        Duel.ConfirmCards(1-tp,g)
        Duel.ShuffleHand(tp)
    else
        Duel.SendtoGrave(g,REASON_COST)
    end
    e:SetCategory(te:GetCategory())
    e:SetProperty(te:GetProperty())
    local tg=te:GetTarget()
    if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
end
function c210171116.operation(e,tp,eg,ep,ev,re,r,rp)
    local te=e:GetLabelObject()
    if not te then return end
    local op=te:GetOperation()
    if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
function c210171116.confilter(c)
    return c:IsSetCard(0xb4) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function c210171116.actcon(e)
    return not Duel.IsExistingMatchingCard(c210171116.confilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil)
end