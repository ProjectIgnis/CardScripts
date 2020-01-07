--Earthbound Resonance
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--damage
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	return #eg==1 and ec:IsPreviousLocation(LOCATION_MZONE) and ec:IsType(TYPE_SYNCHRO)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ec=eg:GetFirst()
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,ec:GetAttack()/2)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	Duel.Damage(1-tp,ec:GetAttack()/2,REASON_EFFECT,true)
	Duel.Damage(tp,ec:GetAttack()/2,REASON_EFFECT,true)
	Duel.RDComplete()
end
