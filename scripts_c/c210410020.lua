--created & coded by Lyris, art by Todd Lockwood
--天剣主翔
function c210410020.initial_effect(c)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetHintTiming(0,0x1c0)
	e0:SetTarget(c210410020.target1)
	e0:SetOperation(c210410020.operation1)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsDefensePos))
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e2:SetDescription(1104)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(c210410020.condition2)
	e2:SetTarget(c210410020.target2)
	e2:SetOperation(c210410020.operation2)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(c210410020.tg)
	e3:SetValue(function(e,re,rp) return rp~=e:GetHandlerPlayer() end)
	c:RegisterEffect(e3)
end
function c210410020.cfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsSetCard(0xfb2)
end
function c210410020.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:SetLabel(0)
	local ct=Duel.GetCurrentChain()
	if ct==1 then return end
	local pe=Duel.GetChainInfo(ct-1,CHAININFO_TRIGGERING_EFFECT)
	if not pe:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	if not pe:GetHandler():IsType(TYPE_SPELL+TYPE_TRAP) or not pe:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	local tg=Duel.GetChainInfo(ct-1,CHAININFO_TARGET_CARDS)
	if not tg or not tg:IsExists(c210410020.cfilter,1,nil) then return end
	if not Duel.IsChainNegatable(ct-1) then return end
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),94) then
		e:SetLabel(1)
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_MZONE)
	end
end
function c210410020.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xfb2) and c:IsAbleToHand()
end
function c210410020.sfilter(c,e,tp,code)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(code)
end
function c210410020.operation1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()~=1 then return end
	if not c:IsRelateToEffect(e) then return end
	local ct=Duel.GetChainInfo(0,CHAININFO_CHAIN_COUNT)
	local tg=Duel.GetChainInfo(ct-1,CHAININFO_TARGET_CARDS)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=tg:FilterSelect(tp,c210410020.filter,1,1,nil)
	local tc=g:GetFirst()
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,c210410020.sfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,tc:GetCode())
		if sg:GetCount()>0 then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
function c210410020.condition2(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	if not re:GetHandler():IsType(TYPE_TRAP) then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not tg or not tg:IsExists(c210410020.cfilter,1,nil) then return false end
	return Duel.IsChainNegatable(ev)
end
function c210410020.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if eg:GetFirst():IsDestructable() then
		eg:GetFirst():CreateEffectRelation(e)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function c210410020.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=tg:FilterSelect(tp,c210410020.filter,1,1,nil)
	local tc=g:GetFirst()
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,c210410020.sfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,tc:GetCode())
		if sg:GetCount()>0 then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
function c210410020.tg(e,c)
	return c:IsFaceup() and c:IsSetCard(0xfb2)
end
