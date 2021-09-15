--烙印の使徒
--Branded Servants
--scripted by Rundas
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Negate an activated monster effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.discon)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	--Destroy the opponent's battled monster(s) with 0 ATK
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
--Negate an activated monster effect
function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_FIEND) and c:IsType(TYPE_FUSION) and c:IsLevelAbove(8)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil) and (rc:IsAttack(0) or rc:IsDefense(0))
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SelectEffectYesNo(tp,e:GetHandler()) then
		Duel.Hint(HINT_CARD,0,id)
		Duel.NegateEffect(ev)
	end
end
--Destroy the opponent's battled monster(s) with 0 ATK
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local a,at=Duel.GetAttacker(),Duel.GetAttackTarget()
	return a and at and a~=at and a:IsAttack(0) and at:IsAttack(0)
	--checked for attack redirection to the same card
end
function s.desfilter(c,tp)
	return c:IsControler(1-tp) and c:IsRelateToBattle()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local a,at=Duel.GetAttacker(),Duel.GetAttackTarget()
	local g=Group.FromCards(a,at):Match(s.desfilter,nil,tp)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,1-tp,LOCATION_MZONE)
	--attack redirection can happen to another monster the opponent controls with 0 atk
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local a,at=Duel.GetAttacker(),Duel.GetAttackTarget()
	local g=Group.FromCards(a,at):Match(s.desfilter,nil,tp)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end