--逆襲！
--Counterattack!
--Made by When
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
        ge1:SetCode(EVENT_BATTLED)
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
    return tp~=Duel.GetTurnPlayer() and Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE and s[tp]
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsMonster,tp,0,LOCATION_MZONE,1,nil) and Duel.IsExistingMatchingCard(Card.IsMonster,tp,LOCATION_MZONE,0,1,nil) and Duel.IsExistingMatchingCard(Card.IsPosition,tp,LOCATION_MZONE,0,1,nil,POS_FACEUP_ATTACK) or Duel.IsExistingMatchingCard(Card.IsPosition,tp,0,LOCATION_MZONE,1,nil,POS_FACEUP_ATTACK) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local g2=Duel.SelectMatchingCard(tp,Card.IsMonster,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	local g1=Duel.SelectMatchingCard(tp,Card.IsMonster,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
	if g1:IsPosition(POS_FACEUP_DEFENSE) or g1:IsPosition(POS_FACEDOWN_DEFENSE) then
	   g2=Duel.SelectMatchingCard(tp,Card.IsPosition,tp,LOCATION_MZONE,0,1,1,nil,POS_FACEUP_ATTACK):GetFirst()
	elseif g2:IsPosition(POS_FACEUP_DEFENSE) or g2:IsPosition(POS_FACEDOWN_DEFENSE) then
	   g1=Duel.SelectMatchingCard(tp,Card.IsPosition,tp,0,LOCATION_MZONE,1,1,nil,POS_FACEUP_ATTACK):GetFirst()
	else
	   g2=Duel.SelectMatchingCard(tp,Card.IsMonster,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	   g1=Duel.SelectMatchingCard(tp,Card.IsMonster,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	if g1:IsPosition(POS_FACEUP_DEFENSE) or g1:IsPosition(POS_FACEDOWN_DEFENSE) and g2:IsPosition(POS_FACEUP_ATTACK) and g1 and g2 then
		Duel.CalculateDamage(g2,g1)
	elseif g2:IsPosition(POS_FACEUP_DEFENSE) or g2:IsPosition(POS_FACEDOWN_DEFENSE) and g1:IsPosition(POS_FACEUP_ATTACK) and g1 and g2 then
	    Duel.CalculateDamage(g1,g2)
	else
	    Duel.CalculateDamage(g2,g1)
	end
end
