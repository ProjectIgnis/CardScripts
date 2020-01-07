--聖蛇の息吹
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,4))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION+TYPE_RITUAL+TYPE_SYNCHRO+TYPE_XYZ)
end
function s.typecast(c)
	return (c:GetType()&TYPE_FUSION+TYPE_RITUAL+TYPE_SYNCHRO+TYPE_XYZ)
end
function s.filter1(c,e)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and c:IsCanBeEffectTarget(e)
end
function s.filter2(c,e)
	return c:IsType(TYPE_TRAP) and c:IsAbleToHand() and c:IsCanBeEffectTarget(e)
end
function s.filter3(c,e)
	return c:IsType(TYPE_SPELL) and c:GetCode()~=id and c:IsAbleToHand() and c:IsCanBeEffectTarget(e)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
	local ct=g:GetClassCount(s.typecast)
	local g1=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e)
	local g2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_GRAVE,0,nil,e)
	local g3=Duel.GetMatchingGroup(s.filter3,tp,LOCATION_GRAVE,0,nil,e)
	if chk==0 then return (ct>1 and #g1>0) or (ct>2 and #g2>0) or (ct>3 and #g3>0) end
	local tg=Group.CreateGroup()
	local off=0
	repeat
		local ops={}
		local opval={}
		off=1
		if ct>1 and #g1>0 then
			ops[off]=aux.Stringid(id,0)
			opval[off-1]=1
			off=off+1
		end
		if ct>2 and #g2>0 then
			ops[off]=aux.Stringid(id,1)
			opval[off-1]=2
			off=off+1
		end
		if ct>3 and #g3>0 then
			ops[off]=aux.Stringid(id,2)
			opval[off-1]=3
			off=off+1
		end
		local op=Duel.SelectOption(tp,table.unpack(ops))
		if opval[op]==1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=g1:Select(tp,1,1,nil)
			tg:Merge(sg)
			g1:Clear()
		elseif opval[op]==2 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=g2:Select(tp,1,1,nil)
			tg:Merge(sg)
			g2:Clear()
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=g3:Select(tp,1,1,nil)
			tg:Merge(sg)
			g3:Clear()
		end
	until off<3 or not Duel.SelectYesNo(tp,aux.Stringid(id,3))
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tg,#tg,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if #sg>0 then
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
