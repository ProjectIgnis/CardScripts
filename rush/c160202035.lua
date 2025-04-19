--サンダービート・ゲイン
--Thunderbeetle Boost

local s,id=GetID()
function s.initial_effect(c)
	--Gain LP equal to 1 of opponent's monster's ATK
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_THUNDER)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttacker():IsLevelBelow(8)
		and Duel.GetAttacker():IsAttackAbove(Duel.GetLP(tp))
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.recfilter(c)
	return c:IsFaceup() and c:GetAttack()>0
end
	--Activation legality
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tg=Duel.GetAttacker()
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(s.recfilter),tp,LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	--Effect
	local g=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(s.recfilter),tp,0,LOCATION_MZONE,1,1,nil)
	if #g>0 then
		g=g:AddMaximumCheck()
		Duel.HintSelection(g)
		local tc=g:GetFirst()
		local rec=tc:GetAttack()
		Duel.Recover(tp,rec,REASON_EFFECT)
	end
end