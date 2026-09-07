--エース・オブ・ワンド
--Ace of Wand
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_COIN+CATEGORY_RECOVER+CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_LEAVE_FIELD)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end
s.toss_coin=true
function s.confilter(c)
    return c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_DESTROY|REASON_EFFECT)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.confilter,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
    Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,0)
    Duel.SetPossibleOperationInfo(0,CATEGORY_RECOVER,nil,0,PLAYER_ALL,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local g=eg:Filter(s.confilter,nil)
    local pg,og=g:Split(Card.IsPreviousControler,nil,tp)
    local psum=0
    local osum=0
    if #pg>0 then
        for tc in pg:Iter() do
            psum=psum+tc:GetPreviousAttackOnField()
        end
    end
    if #og>0 then
        for tc in og:Iter() do
            osum=osum+tc:GetPreviousAttackOnField()
        end
    end
    local res=Duel.TossCoin(tp,1)
    if res==COIN_HEADS then
        if #pg>0 then
            Duel.Recover(tp,psum,REASON_EFFECT)
        end
        if #og>0 then
            Duel.Recover(1-tp,osum,REASON_EFFECT)
        end
    elseif res==COIN_TAILS then
        if #pg>0 then
            Duel.Damage(tp,psum,REASON_EFFECT)
        end
        if #og>0 then
            Duel.Damage(1-tp,osum,REASON_EFFECT)
        end
    end
end
