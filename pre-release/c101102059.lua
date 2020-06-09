--双天の調伏
--Souten Exorcism
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end
s.listed_series={0x247}
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(aux.FilterFaceupFunction(Card.IsSetCard,0x247),tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g1=Duel.SelectTarget(tp,aux.FilterFaceupFunction(Card.IsSetCard,0x247),tp,LOCATION_MZONE,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g2=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
function s.filter(c,tp)
	return c:IsSetCard(0x247) and c:IsType(TYPE_FUSION) and c:IsPreviousControler(tp)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if #tg>0 and Duel.Destroy(tg,REASON_EFFECT)>0 then
		local og=Duel.GetOperatedGroup():Filter(s.filter,nil,tp)
		local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,nil)
		local opt1=Duel.IsPlayerCanDraw(tp,1)
		local opt2=#g>0
		if #og>0 and (opt1 or opt2) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			local opt
			if opt1 and opt2 then
				opt=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
			elseif opt1 and not opt2 then
				opt=Duel.SelectOption(tp,aux.Stringid(id,1))
			elseif opt2 and not opt1 then
				opt=Duel.SelectOption(tp,aux.Stringid(id,2))+1
			end
			if opt==0 then
				Duel.BreakEffect()
				Duel.Draw(tp,1,REASON_EFFECT)
			elseif opt==1 then
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
				local sg=g:Select(tp,1,1,nil)
				Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
			end
		end
	end
end