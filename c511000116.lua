--Spirit Shield
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
	--negate
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetCondition(s.atkcon)
	e2:SetCost(s.atkcost)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	--self destroy
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SELF_DESTROY)
	e3:SetCondition(s.descon)
	c:RegisterEffect(e3)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return true end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local label=e:GetLabel()
	if chk==0 then
		if label==1 then e:SetLabel(0) end
		return true
	end
	if Duel.CheckEvent(EVENT_ATTACK_ANNOUNCE) and s.atkcon(e,tp,eg,ep,ev,re,r,rp) and (label~=1 or s.atkcost(e,tp,eg,ep,ev,re,r,rp,0)) 
		and Duel.SelectYesNo(tp,aux.Stringid(81443745,1)) then
		e:SetOperation(s.atkop)
		if label==1 then
			s.atkcost(e,tp,eg,ep,ev,re,r,rp,1)
		end
	else
		e:SetOperation(nil)
	end
end
function s.descon(e)
	return not Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsRace,RACE_FIEND+RACE_ZOMBIE),e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp)
end
function s.cfilter(c)
	return c:IsRace(RACE_FIEND+RACE_ZOMBIE) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return false end
	if Duel.NegateAttack() then
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE,1)
	end
end
