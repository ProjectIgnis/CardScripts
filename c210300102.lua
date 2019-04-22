--Noble Knight of White Laundsaullyn
function c210300102.initial_effect(c)
    --special summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(210300102,0))
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
    e1:SetCountLimit(1,210300102)
    e1:SetTarget(c210300102.sptg)
    e1:SetOperation(c210300102.spop)
    c:RegisterEffect(e1)
    --pop
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,210310102)
    e2:SetHintTiming(0,0x1e0)
    e2:SetTarget(c210300102.destg)
    e2:SetOperation(c210300102.desop)
    c:RegisterEffect(e2)
end
function c210300102.desfilter(c)
    return c:IsSetCard(0x207a) and c:IsType(TYPE_SPELL) and ((c:IsLocation(LOCATION_SZONE) and c:IsFaceup()) or c:IsLocation(LOCATION_HAND))
end
function c210300102.locfilter(c,tp)
    return c:IsLocation(LOCATION_SZONE) and c:IsControler(tp)
end
function c210300102.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
    local loc=LOCATION_SZONE+LOCATION_HAND
    if ft<0 then loc=LOCATION_SZONE end
    local loc2=0
    if Duel.IsPlayerAffectedByEffect(tp,88581108) then loc2=LOCATION_SZONE end
    local g=Duel.GetMatchingGroup(c210300102.desfilter,tp,loc,loc2,c)
    if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
        and g:GetCount()>=2 and g:IsExists(Card.IsSetCard,1,nil,0x207a)
        and (ft>0 or g:IsExists(c210300102.locfilter,-ft+1,nil,tp)) end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,2,tp,loc)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function c210300102.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    local loc=LOCATION_SZONE+LOCATION_HAND
    if ft<0 then loc=LOCATION_SZONE end
    local loc2=0
    if Duel.IsPlayerAffectedByEffect(tp,88581108) then loc2=LOCATION_SZONE end
    local g=Duel.GetMatchingGroup(c210300102.desfilter,tp,loc,loc2,c)
    if g:GetCount()<2 or not g:IsExists(Card.IsSetCard,1,nil,0x207a) then return end
    local g1=nil local g2=nil
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    if ft<1 then
        g1=g:FilterSelect(tp,c210300102.locfilter,1,1,nil,tp)
    else
        g1=g:Select(tp,1,1,nil)
    end
    g:RemoveCard(g1:GetFirst())
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    if g1:GetFirst():IsSetCard(0x207a) then
        g2=g:Select(tp,1,1,nil)
    else
        g2=g:FilterSelect(tp,Card.IsSetCard,1,1,nil,0x207a)
    end
    g1:Merge(g2)
    local rm=g1:IsExists(Card.IsSetCard,2,nil,0x207a)
    if Duel.Destroy(g1,REASON_EFFECT)==2 then
        if not c:IsRelateToEffect(e) then return end
        if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP)==0 then
           Duel.SpecialSummonComplete()
        end
    end
end
function c210300102.desfilter1(c)
    return c:IsFaceup() and c:IsSetCard(0x207a) and c:IsType(TYPE_SPELL)
end
function c210300102.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return false end
    if chk==0 then return Duel.IsExistingTarget(c210300102.desfilter1,tp,LOCATION_ONFIELD,0,1,nil)
        and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g1=Duel.SelectTarget(tp,c210300102.desfilter1,tp,LOCATION_ONFIELD,0,1,1,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g2=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
    g1:Merge(g2)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
function c210300102.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    local tg=g:Filter(Card.IsRelateToEffect,nil,e)
    if tg:GetCount()>0 then
        Duel.Destroy(tg,REASON_EFFECT)
    end
end
