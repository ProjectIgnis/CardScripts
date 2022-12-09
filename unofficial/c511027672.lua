--ミラーイマジン・リフレクター１ワン-3
--Mirror Imagine Reflector 3
--Made by Beetron-1 Beetletop
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCost(s.cost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
function s.atkfilter1(c,e,tp)
	local ec=e:GetHandler()
	return ec==Duel.GetAttackTarget() and Duel.GetAttacker():IsAttackBelow(1000)
end
function s.atkfilter2(c,a)
	return a:GetAttackableTarget():IsContains(c)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local a=Duel.GetAttacker()
	local b1=Duel.IsExistingMatchingCard(s.atkfilter2,tp,LOCATION_MZONE,0,1,Group.FromCards(a,Duel.GetAttackTarget()),a)
	local b2=Duel.IsExistingTarget(s.atkfilter1,tp,0,LOCATION_MZONE,1,nil,e,tp)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,0)},
		{b2,aux.Stringid(id,1)})
	e:SetLabel(op)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	op=e:GetLabel()
		if op==1 then
			local a=Duel.GetAttacker()
			local g=Duel.SelectMatchingCard(tp,s.atkfilter2,tp,LOCATION_MZONE,0,1,1,Group.FromCards(a,Duel.GetAttackTarget()),a)
				if #g>0 then
					Duel.HintSelection(g)
					Duel.ChangeAttackTarget(g:GetFirst())
				end
		else
			Duel.NegateAttack()
		end
end