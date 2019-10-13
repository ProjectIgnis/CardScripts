--Aiシャドー
--A.I. Shadow
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
    aux.AddPersistentProcedure(c,0,aux.FilterFaceupFunction(Card.IsSetCard,0x135),CATEGORY_ATKCHANGE,EFFECT_FLAG_DAMAGE_STEP,TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP,s.condition)
    --atk up
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_SZONE)
    e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e1:SetTarget(aux.PersistentTargetFilter)
    e1:SetValue(800)
    c:RegisterEffect(e1)
    --must attack
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_MUST_ATTACK)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTargetRange(0,LOCATION_MZONE)
    e2:SetCondition(s.atkcon)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EFFECT_MUST_ATTACK_MONSTER)
    c:RegisterEffect(e3)
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_MUST_BE_ATTACKED)
    e4:SetRange(LOCATION_SZONE)
    e4:SetTargetRange(LOCATION_MZONE,0)
    e4:SetTarget(aux.PersistentTargetFilter)
    e4:SetValue(1)
    c:RegisterEffect(e4)
    --draw
    local e5=Effect.CreateEffect(c)
    e5:SetCategory(CATEGORY_DRAW)
    e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e5:SetCode(EVENT_TO_GRAVE)
    e5:SetProperty(EFFECT_FLAG_DELAY)
    e5:SetCountLimit(1,id)
    e5:SetCondition(s.drcon)
    e5:SetTarget(s.drtg)
    e5:SetOperation(s.drop)
    c:RegisterEffect(e5)
    local e6=e5:Clone()
    e6:SetCode(EVENT_REMOVE)
    c:RegisterEffect(e6)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetCurrentPhase()~=PHASE_DAMAGE or not Duel.IsDamageCalculated()
end
function s.atkcon(e)
    return Duel.GetTurnPlayer()~=e:GetHandlerPlayer() and e:GetHandler():GetCardTargetCount()>0
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsReason(REASON_EFFECT) and rp~=tp and c:GetPreviousControler()==tp
        and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(1)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Draw(p,d,REASON_EFFECT)
end

