function c210310115.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCondition(c210310115.condition)
	e1:SetTarget(c210310115.target)
	e1:SetOperation(c210310115.operation)
	c:RegisterEffect(e1)
end
function c210310115.cfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:GetPreviousControler()==tp and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsSetCard(0xf33)
end
function c210310115.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c210310115.cfilter,1,nil,tp) and not Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,0,1,eg)
end
function c210310115.cfilter2(c,atk)
	if not c:IsSetCard(0xf33) or not c:IsAbleToRemoveAsCost() or not (c:GetAttack()>=atk) then return false end
	if Duel.IsPlayerAffectedByEffect(c:GetControler(),69832741) then
		return c:IsFaceup() and c:IsLocation(LOCATION_MZONE)
	else
		return c:IsLocation(LOCATION_GRAVE)
	end
end
function c210310115.desfilter2(c,num)
	return c:IsFaceup() and c:IsAttackBelow(num)
end
function c210310115.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		if not Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) then return false end
		local tg=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		local tc=tg:GetMinGroup(Card.GetAttack):GetFirst()
		return Duel.IsExistingMatchingCard(c210310115.cfilter2,tp,LOCATION_GRAVE+LOCATION_MZONE,0,1,nil,tc:GetAttack()) 
	end
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local c=g:GetMinGroup(Card.GetAttack):GetFirst()
	local tg=Duel.SelectTarget(tp,c210310115.cfilter2,tp,LOCATION_GRAVE+LOCATION_MZONE,0,1,1,nil,c:GetAttack())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,tg,1,0,0)
end
function c210310115.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT) then
		local num=tc:GetAttack()
		local g=Duel.GetMatchingGroup(c210310115.desfilter2,tp,0,LOCATION_MZONE,nil,num)
		if g:GetCount()==0 then return end
		local dg=Group.CreateGroup()
		repeat
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local tg=g:FilterSelect(tp,c210310115.desfilter2,1,1,nil,num)
			local tc=tg:GetFirst()
			num=num-tc:GetAttack()
			g:RemoveCard(tc)
			dg:AddCard(tc)
		until not g:IsExists(c210310115.desfilter2,1,nil,num) or not Duel.SelectYesNo(tp,aux.Stringid(28265983,3))
		Duel.Destroy(dg,REASON_EFFECT)
	end
end