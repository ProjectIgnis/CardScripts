local s,id=GetID()
function s.initial_effect(c)
	--Force a Battle
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
        s[0]=true
        s[1]=true
        local ge1=Effect.CreateEffect(c)
        ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge1:SetCode(EVENT_DAMAGE_STEP_END)
        ge1:SetOperation(s.checkop)
        Duel.RegisterEffect(ge1,0)
        local ge2=Effect.CreateEffect(c)
        ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge2:SetCode(EVENT_ADJUST)
        ge2:SetCountLimit(1)
        ge2:SetOperation(s.clear)
        Duel.RegisterEffect(ge2,0)
    end)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
    local at=Duel.GetAttackTarget()
    if at and at:IsRelateToBattle() then
        s[at:GetControler()]=true
    end
end
function s.clear(e,tp,eg,ep,ev,re,r,rp)
    s[0]=false
    s[1]=false
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    local ph=Duel.GetCurrentPhase()
    return ph>=0x08 and ph<=0x20 and Duel.GetTurnPlayer()~=tp and s[tp]
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g1=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	local g2=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
	local tc1=g1:GetFirst()
	local tc2=g2:GetFirst()
	if tc1:IsPosition(POS_FACEUP_ATTACK) or tc2:IsPosition(POS_FACEUP_ATTACK) and tc1 and tc2 then
		Duel.CalculateDamage(tc1,tc2)
	end
end