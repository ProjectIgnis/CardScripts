--－Ａｉ－コンタクト (Anime)
--A.I. Contact (Anime)
--Scripted by Larry126
local s,id,alias=GetID()
function s.initial_effect(c)
	alias=c:GetOriginalCodeRule()
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,alias)--+EFFECT_COUNT_CODE_OATH
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.rdfilter(c,code)
	return c:IsCode(code) and c:IsAbleToDeck()
end
function s.filter(c,p)
	return c:IsFaceup() and Duel.IsExistingMatchingCard(s.rdfilter,p,LOCATION_HAND,0,1,nil,c:GetCode())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_FZONE) and s.filter(chkc,tp) end
	if chk==0 then return Duel.IsPlayerCanDraw(tp,3)
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil,tp) end
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_FZONE,LOCATION_FZONE,1,1,nil,tp)
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(3)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,3)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local rg=Duel.SelectMatchingCard(tp,s.rdfilter,tp,LOCATION_HAND,0,1,1,nil,tc:GetCode())
		if #rg>0 then
			Duel.ConfirmCards(1-tp,rg)
			Duel.SendtoDeck(rg,nil,2,REASON_EFFECT)
			Duel.ShuffleDeck(tp)
			Duel.BreakEffect()
			local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
			Duel.Draw(p,d,REASON_EFFECT)
		end
	end
end
