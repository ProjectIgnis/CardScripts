--Fluffal Wing
local s,id=GetID()
function s.initial_effect(c)
	--banish, draw
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(s.con)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
s.listed_names={70245411,72413000}
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(70245411)
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.filter(c)
	return c:IsCode(72413000) and c:IsAbleToRemove() and aux.SpElimFilter(c,true)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,2,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,2,0,0)
end
function s.trfilter(c)
	return c:IsReleasableByEffect() and c:IsCode(70245411)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if g:FilterCount(Card.IsRelateToEffect,nil,e)==2 then
		if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
			Duel.BreakEffect()
			if Duel.Draw(tp,2,REASON_EFFECT) and Duel.IsPlayerCanDraw(tp,1) 
				and Duel.IsExistingMatchingCard(s.trfilter,tp,LOCATION_ONFIELD,0,1,nil) 
				and Duel.SelectYesNo(tp,aux.Stringid(90434926,1)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
				local tr=Duel.SelectMatchingCard(tp,s.trfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
				if #tr>0 and Duel.Release(tr,REASON_EFFECT)~=0 then
					Duel.Draw(tp,1,REASON_EFFECT)
				end
			end
		end
	end
end
