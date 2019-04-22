--Merlin's Apprentice
function c210300101.initial_effect(c)
    --special summon
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCode(EVENT_CHAINING)
    e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
    e1:SetOperation(aux.chainreg)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(210300101,0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
    e2:SetCode(EVENT_CHAIN_SOLVING)
    e2:SetCountLimit(1,210300101)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCondition(c210300101.spcon)
    e2:SetTarget(c210300101.sptg)
    e2:SetOperation(c210300101.spop)
    c:RegisterEffect(e2)
    --destroy
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(210300101,1))
    e3:SetCategory(CATEGORY_DESTROY)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,210310101)
    e3:SetCondition(c210300101.descon)
    e3:SetCost(aux.bfgcost)
    e3:SetTarget(c210300101.destg)
    e3:SetOperation(c210300101.desop)
    c:RegisterEffect(e3)
end
function c210300101.spcon(e,tp,eg,ep,ev,re,r,rp)
    local c=re:GetHandler()
    return rp==tp and re:GetHandler():IsCode(3580032) and e:GetHandler():GetFlagEffect(1)>0
end
function c210300101.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c210300101.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
        e1:SetValue(LOCATION_DECKSHF)
        e1:SetReset(RESET_EVENT+0x47e0000)
        c:RegisterEffect(e1,true)
    end
end
function c210300101.cfilter(c)
    return c:IsFaceup() and (c:IsSetCard(0xa7) or c:IsSetCard(0xa8)) 
end
function c210300101.descon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(c210300101.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c210300101.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
    if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c210300101.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.Destroy(tc,REASON_EFFECT)
    end
end
