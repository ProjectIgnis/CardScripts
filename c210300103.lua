--Noble Knight Mordred
function c210300103.initial_effect(c)
    --link summon
    c:EnableReviveLimit()
    aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x107a),2,2)
    --Xyz Summon using Noble Arms
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(210300103,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCondition(c210300103.spcon)
    e1:SetTarget(c210300103.sptg)
    e1:SetOperation(c210300103.spop)
    c:RegisterEffect(e1)
    --Special Summon 1 Noble Knight Synchro Monster from your Extra Deck or GY
    local e2=Effect.CreateEffect(c) 
    e2:SetDescription(aux.Stringid(210300103,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCost(c210300103.spcost1)
    e2:SetTarget(c210300103.sptg1)
    e2:SetOperation(c210300103.spop1)
    c:RegisterEffect(e2)
end
function c210300103.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function c210300103.filter(c,e,tp)
    return c:IsType(TYPE_XYZ) and c:IsSetCard(0x107a) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function c210300103.filter2(c)
    return c:IsFaceup() and c:IsSetCard(0x207a) and c:IsType(TYPE_SPELL)
end
function c210300103.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return false end
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(c210300103.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) 
        and Duel.IsExistingTarget(c210300103.filter2,tp,LOCATION_GRAVE+LOCATION_SZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g1=Duel.SelectTarget(tp,c210300103.filter2,tp,LOCATION_GRAVE+LOCATION_SZONE,0,2,2,nil)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,1,0,0)
end
function c210300103.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCountFromEx(tp)<=0 then return end
    local g=Duel.GetMatchingGroup(c210300103.filter,tp,LOCATION_EXTRA,0,nil,e,tp)
    if g:GetCount()==0 then return end
    local mg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
    if mg:GetCount()~=2 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=g:Select(tp,1,1,nil)
    local sc=sg:GetFirst()
    if sc then
        Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
        Duel.Overlay(sc,mg)
    end
end
function c210300103.cfilter(c)
    return c:IsSetCard(0x207a) and c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end
function c210300103.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
        and Duel.IsExistingMatchingCard(c210300103.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,c210300103.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    g:AddCard(e:GetHandler())
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c210300103.spfilter1(c,e,tp)
    return c:IsType(TYPE_SYNCHRO) and c:IsSetCard(0x107a) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end
function c210300103.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCountFromEx(tp,tp,e:GetHandler())>0
        and Duel.IsExistingMatchingCard(c210300103.spfilter1,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA+LOCATION_GRAVE)
end
function c210300103.spop1(e,tp,eg,ep,ev,re,r,rp)
    local ft=Duel.GetLocationCountFromEx(tp)
    if ft<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local tc=Duel.SelectMatchingCard(tp,c210300103.spfilter1,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
    if tc then
        Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
        tc:CompleteProcedure()
    end
end
