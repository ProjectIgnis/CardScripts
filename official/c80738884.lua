--ＶＳ龍帝ノ槍
--Vanquish Soul - Calamity Kaiser 
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_VANQUISH_SOUL}
function s.filter(c,p)
	return c:IsOnField() and c:IsControler(p)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_VANQUISH_SOUL),tp,LOCATION_MZONE,0,1,nil) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg:IsExists(s.filter,1,nil,tp) and Duel.IsChainNegatable(ev)
		and (re:IsMonsterEffect() or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	local rc=re:GetHandler()
	if rc:IsDestructable() and rc:IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
		Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
	end
end
function s.damfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_VANQUISH_SOUL) and c:GetAttack()>0
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)>0 then
		local g=Duel.GetMatchingGroup(s.damfilter,tp,LOCATION_MZONE,0,nil)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
			local tc=g:Select(tp,1,1,nil):GetFirst()
			Duel.HintSelection(tc,true)
			local dam=tc:GetAttack()
			Duel.BreakEffect()
			Duel.Damage(1-tp,dam,REASON_EFFECT)
		end
	end
end