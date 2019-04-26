--Ignoble Arms - Shadowvere
function c210300105.initial_effect(c)
    c:SetUniqueOnField(1,0,210300105)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetTarget(c210300105.target)
    e1:SetOperation(c210300105.operation)
    c:RegisterEffect(e1)
    --spsummon
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_SZONE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,210300105)
    e2:SetTarget(c210300105.sptg)
    e2:SetOperation(c210300105.spop)
    c:RegisterEffect(e2)
    --Equip limit
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_EQUIP_LIMIT)
    e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e3:SetValue(c210300105.eqlimit)
    c:RegisterEffect(e3)
    --equip
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(210300105,1))
    e5:SetCategory(CATEGORY_EQUIP)
    e5:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
    e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e5:SetCode(EVENT_TO_GRAVE)
    e5:SetCountLimit(1,210310105)
    e5:SetCondition(c210300105.eqcon)
    e5:SetTarget(c210300105.eqtg)
    e5:SetOperation(c210300105.operation)
    c:RegisterEffect(e5)
end
function c210300105.eqlimit(e,c)
    return c:IsRace(RACE_WARRIOR)
end
function c210300105.eqfilter1(c)
    return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
function c210300105.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and c210300105.eqfilter1(chkc) end
    if chk==0 then return Duel.IsExistingTarget(c210300105.eqfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    Duel.SelectTarget(tp,c210300105.eqfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function c210300105.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() and c:CheckUniqueOnField(tp) then
        Duel.Equip(tp,c,tc)
    end
end
function c210300105.filter(c,e,tp)
    return c:IsSetCard(0x107a) and c:GetLevel()>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function c210300105.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c210300105.filter(chkc,e,tp) end
    if chk==0 then return Duel.IsExistingTarget(c210300105.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,c210300105.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function c210300105.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+0x1fe0000)
        tc:RegisterEffect(e1)
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        e2:SetReset(RESET_EVENT+0x1fe0000)
        tc:RegisterEffect(e2)
        local e3=Effect.CreateEffect(c)
        e3:SetType(EFFECT_TYPE_SINGLE)
        e3:SetCode(EFFECT_CHANGE_LEVEL)
        e3:SetValue(5)
        e3:SetReset(RESET_EVENT+0x1fe0000)
        tc:RegisterEffect(e3)
        local e4=Effect.CreateEffect(c)
        e4:SetType(EFFECT_TYPE_SINGLE)
        e4:SetCode(EFFECT_CHANGE_ATTRIBUTE)
        e4:SetValue(ATTRIBUTE_DARK)
        e4:SetReset(RESET_EVENT+0x1fe0000)
        tc:RegisterEffect(e4)
    end
    Duel.SpecialSummonComplete()
end
function c210300105.eqcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP) and c:IsReason(REASON_DESTROY) and c:CheckUniqueOnField(tp)
end
function c210300105.eqfilter2(c)
    return c:IsFaceup() and c:IsSetCard(0x107a) and c:IsRace(RACE_WARRIOR)
end
function c210300105.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c210300105.eqfilter2(chkc) end
    if chk==0 then return e:GetHandler():IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
        and Duel.IsExistingTarget(c210300105.eqfilter2,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    Duel.SelectTarget(tp,c210300105.eqfilter2,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
