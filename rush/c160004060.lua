--獣機界奥義 獣之拳
--Beast Gear Secret Art - Primal Fist
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.atkcon)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
end
function s.atkfilter(c)
	return c:IsLevelBetween(7,9) and c:IsRace(RACE_FIEND|RACE_BEASTWARRIOR|RACE_MACHINE) and c:IsFaceup()
end
function s.atkfilter2(c)
	return c:IsRace(RACE_FAIRY|RACE_DRAGON|RACE_SPELLCASTER) and c:IsFaceup()
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttackTarget()
	return at and at:IsControler(tp) and s.atkfilter(at)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local a=Duel.GetAttacker()
		return a:IsAttackPos() and a:IsCanChangePositionRush()
	end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	if a and a:IsAttackPos() and a:IsRelateToBattle() then
		Duel.ChangePosition(a,POS_FACEUP_DEFENSE)
		if a:IsPreviousPosition(POS_FACEUP_ATTACK) and s.atkfilter2(a) and Duel.GetFieldGroupCount(tp,0,LOCATION_SZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local sg=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_SZONE,1,1,nil)
			if #sg>0 then
				Duel.Destroy(sg,REASON_EFFECT)
			end
		end
	end
end