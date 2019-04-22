--Wicked Rites
function c210660004.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c210660004.target)
	e1:SetOperation(c210660004.activate)
	c:RegisterEffect(e1)
end
function c210660004.filter(c)
	return c:IsCode(21208154,57793869,62180201) and Duel.IsExistingMatchingCard(c210660004.dfilter,tp,LOCATION_HAND,0,1,c)
end
function c210660004.dfilter(c)
	return c:IsDiscardable(REASON_EFFECT) and c:IsCode(21208154,57793869,62180201)
end
function c210660004.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c210660004.filter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local cg=Duel.SelectMatchingCard(tp,c210660004.filter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.ConfirmCards(1-tp,cg)
	e:SetLabelObject(cg:GetFirst())
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(c210660004.chlimit)
	end
end
function c210660004.chlimit(e,ep,tp)
	return tp==ep
end
function c210660004.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if not tc:IsLocation(LOCATION_HAND) or not Duel.IsExistingMatchingCard(c210660004.dfilter,tp,LOCATION_HAND,0,1,tc) then return end
	if Duel.DiscardHand(tp,c210660004.dfilter,1,1,REASON_EFFECT+REASON_DISCARD,tc)>0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(30435145,0))
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
		e1:SetCondition(c210660004.ntcon)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
function c210660004.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and c:GetLevel()>4 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end