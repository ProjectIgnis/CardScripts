--Millennium Eye Vision
--Original ideia by Hooded Red™#7087
--scripted by Hooded Red™#7087 / Added to Naim's range
function c210777044.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetOperation(c210777044.activate)
    e1:SetCountLimit(1,210777044)
    c:RegisterEffect(e1)
    --Cannot be targeted
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetTarget(c210777044.target)
    e2:SetValue(aux.tgoval)
    c:RegisterEffect(e2)
    --Indestructable
    local e3=e2:Clone()
    e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    e3:SetValue(c210777044.indesval)
    c:RegisterEffect(e3)
    --Banish & Grant Direct Attack
    local e4=Effect.CreateEffect(c)
    e4:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_GRAVE)
    e4:SetCost(aux.bfgcost)
    e4:SetCondition(c210777044.condition)
    e4:SetOperation(c210777044.operation)
    c:RegisterEffect(e4)
end
function c210777044.thfilter(c)
    return c:IsAbleToHand() and (
	c:IsCode(27125110) or
	c:IsCode(15173384) or
	c:IsCode(28546905) or
	c:IsCode(38247752) or
	c:IsCode(89785779)
	)
end
function c210777044.activate(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local g=Duel.GetMatchingGroup(c210777044.thfilter,tp,LOCATION_DECK,0,nil)
    if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(210777044,0)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local sg=g:Select(tp,1,1,nil)
        Duel.SendtoHand(sg,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,sg)
    end
end
function c210777044.target(e,c)
    return c:GetBaseAttack()==0 and (c:IsLevel(1) or c:IsLink(1))
end
function c210777044.indesval(e,re,rp)
	return rp~=e:GetHandlerPlayer()
end
function c210777044.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetMatchingGroupCount(c210777044.target,tp,LOCATION_MZONE,0,nil)>0
end
function c210777044.operation(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(c210777044.target,tp,LOCATION_MZONE,0,nil)
    local tc=g:GetFirst()
    while tc do
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DIRECT_ATTACK)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
        tc=g:GetNext()
    end
end