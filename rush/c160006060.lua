--魔将決闘斬
--Dark Ruler Battle Slash
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.atkcon)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
end
function s.atkfilter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsFaceup()
end
function s.atkfilter2(c)
	return c:IsRace(RACE_WARRIOR) and c:IsLevelAbove(8) and c:IsFaceup()
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttackTarget()
	return at and at:IsControler(tp) and s.atkfilter(at)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetAttacker() end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	if a and a:IsAttackPos() and a:IsRelateToBattle() then
		--atk decrease
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-400)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		a:RegisterEffect(e1)
		if Duel.IsExistingMatchingCard(s.atkfilter2,tp,LOCATION_MZONE,0,1,nil,tp) and Duel.GetFieldGroupCount(tp,0,LOCATION_SZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local sg=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_SZONE,1,1,nil)
			if #sg>0 then
				Duel.HintSelection(sg)
				Duel.Destroy(sg,REASON_EFFECT)
			end
		end
	end
end