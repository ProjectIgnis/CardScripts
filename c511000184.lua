--Number 14: Greedy Sarameya
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	aux.AddXyzProcedure(c,nil,5,2)
	c:EnableReviveLimit()
	--Trick Battle effect
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetCondition(s.tbcon)
	e1:SetCost(s.tbcost)
	e1:SetOperation(s.tbop)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
	--battle indestructable
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(s.indes)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_ADJUST)
		ge2:SetCountLimit(1)
		ge2:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
		ge2:SetOperation(s.numchk)
		Duel.RegisterEffect(ge2,0)
	end
end
s.xyz_number=14
function s.tbcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=Duel.GetAttacker()
	if bc==c then bc=Duel.GetAttackTarget() end
	return bc and bc:IsFaceup() and bc:GetAttack()>c:GetAttack()
end
function s.tbcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.tbop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=Duel.GetAttacker()
	if bc==c then
		bc=Duel.GetAttackTarget()
	end
	if bc:GetAttack()>c:GetAttack() then
		local dam=bc:GetAttack()-c:GetAttack()
		Duel.Damage(1-tp,dam,REASON_BATTLE)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
		c:RegisterEffect(e1)
		Duel.Destroy(bc,REASON_BATTLE)
	else
		local dam=c:GetAttack()-bc:GetAttack()
		Duel.Damage(1-tp,dam,REASON_BATTLE)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
		bc:RegisterEffect(e1)
		Duel.Destroy(c,REASON_BATTLE)
	end
	if Duel.IsExistingTarget(s.dfilter,tp,0,LOCATION_MZONE,1,nil,bc:GetAttack()) then
		local g=Duel.SelectMatchingCard(tp,s.dfilter,tp,0,LOCATION_MZONE,1,1,nil,bc:GetAttack())
		Duel.Destroy(g,REASON_EFFECT)
	end
end
function s.dfilter(c,atk)
	return c:IsFaceup() and c:IsDestructable() and c:GetAttack()<=atk
end
function s.numchk(e,tp,eg,ep,ev,re,r,rp)
	Duel.CreateToken(tp,21313376)
	Duel.CreateToken(1-tp,21313376)
end
function s.indes(e,c)
	return not c:IsSetCard(0x48)
end
