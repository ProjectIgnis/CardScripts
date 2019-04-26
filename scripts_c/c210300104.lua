--Holy Noble Knight Crusader, Artorigus
function c210300104.initial_effect(c)
    --synchro summon
	aux.AddSynchroProcedure(c,nil,1,1,aux.NonTunerEx(Card.IsSetCard,0x107a),1,99)
    c:EnableReviveLimit()
    --ret&draw
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(210300104,0))
    e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTarget(c210300104.drtg)
    e1:SetOperation(c210300104.drop)
    c:RegisterEffect(e1)
    --spec&des
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(210300104,1))
    e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1)
    e2:SetHintTiming(0,0x1e0)
    e2:SetTarget(c210300104.destg)
    e2:SetOperation(c210300104.desop)
    c:RegisterEffect(e2)
end
function c210300104.drfilter(c)
    return (c:IsSetCard(0x107a) or c:IsSetCard(0x207a)) or c:IsCode(82140600,3580032,10736540) and not c:IsCode(45531624) and c:IsAbleToDeck()
end
function c210300104.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c210300104.drfilter(chkc) end
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsExistingTarget(c210300104.drfilter,tp,LOCATION_GRAVE,0,2,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectTarget(tp,c210300104.drfilter,tp,LOCATION_GRAVE,0,2,2,nil)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c210300104.drop(e,tp,eg,ep,ev,re,r,rp)
    local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=2 then return end
    Duel.SendtoDeck(tg,nil,0,REASON_EFFECT)
    local g=Duel.GetOperatedGroup()
    if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
    local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
    if ct==2 then
        Duel.BreakEffect()
        Duel.Draw(tp,1,REASON_EFFECT)
    end
end
function c210300104.desfilter(c)
    return c:IsSetCard(0x207a) and c:IsType(TYPE_EQUIP)
end
function c210300104.spfilter(c,e,tp)
    return c:IsSetCard(0x107a) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c210300104.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(tp) and c210300104.desfilter(chkc) end
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(c210300104.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
        and Duel.IsExistingTarget(c210300104.desfilter,tp,LOCATION_ONFIELD,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,c210300104.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c210300104.desop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,c210300104.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
    if g:GetCount()>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) 
        local tc=Duel.GetFirstTarget()
        if tc:IsRelateToEffect(e) then
            Duel.Destroy(tc,REASON_EFFECT)
        end
    end
end
