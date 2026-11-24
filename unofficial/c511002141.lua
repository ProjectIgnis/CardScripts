--守るべき者
--The One to be Protected
local s,id=GetID()
function s.initial_effect(c)
	--Send 1 monster from your Deck to the GY with equal or greater ATK than the attacking monster, but lose LP equal to the ATK of the sent monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local a,at=Duel.GetAttacker(),Duel.GetAttackTarget()
	return at and a:IsControler(1-tp) and aux.StatChangeDamageStepCondition()
end
function s.costfilter(c,atk)
	return c:IsAbleToGraveAsCost() and c:IsAttackAbove(atk)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return true end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK,0,1,nil,Duel.GetAttacker():GetAttack()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sc=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_DECK,0,1,1,nil,Duel.GetAttacker():GetAttack()):GetFirst()
	local atk=sc:GetAttack()
	Duel.SendtoGrave(sc,REASON_COST)
	Duel.SetTargetParam(atk)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local a,at=Duel.GetAttacker(),Duel.GetAttackTarget()
	local atk=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if not at or not at:IsRelateToBattle() then return end
	--Monsters cannot be destroyed by that battle
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_SINGLE)
	e1a:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1a:SetValue(1)
	e1a:SetReset(RESET_PHASE|PHASE_DAMAGE)
	a:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	at:RegisterEffect(e1b)
	--Neither player takes battle damage from that battle
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e2:SetTargetRange(1,1)
	e2:SetReset(RESET_PHASE|PHASE_DAMAGE)
	Duel.RegisterEffect(e2,tp)
	--You lose LP equal to the ATK of the sent monster
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BATTLED)
	e3:SetOperation(s.lplossop)
	e3:SetLabel(atk)
	e3:SetReset(RESET_PHASE|PHASE_DAMAGE)
	Duel.RegisterEffect(e3,tp)
end
function s.lplossop(e,tp,eg,ep,ev,re,r,rp)
	local lp_loss=e:GetLabel()
	if lp_loss()>0 then
		local lp=Duel.GetLP(tp)
		Duel.Hint(HINT_CARD,0,id)
		Duel.SetLP(tp,lp-lp_loss)
	end
end
