--ドラグマ・ジェネシス
--Dogmatika Genesis
--Logical Nonsense
--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Negate 1 of opponent's monsters
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
	--Check for a fusion, synchro, Xyz, or link monster 
function s.filter1(c,tp)
	local typ=c:GetType()&(TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK)
	return c:IsFaceup() and typ~=0 and c:IsAbleToExtra()
		and Duel.IsExistingTarget(s.filter2,tp,0,LOCATION_MZONE,1,nil,typ)
end
	--Check for an effect monster with same card type from filter1
function s.filter2(c,ex)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsType(ex) and not c:IsDisabled()
end
	--Activation legality
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.filter1,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g1=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil,tp)
	local typ=g1:GetFirst():GetType()&(TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g2=Duel.SelectTarget(tp,s.filter2,tp,0,LOCATION_MZONE,1,1,nil,typ)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,1,0,LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g2,1,0,0)
end
	--Return 1 banished monster to extra deck, and if you do, negate targeted monster's effects
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ex,g1=Duel.GetOperationInfo(0,CATEGORY_TODECK)
	local ex,g2=Duel.GetOperationInfo(0,CATEGORY_DISABLE)
	if g1:GetFirst():IsRelateToEffect(e) then
		Duel.SendtoDeck(g1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		local og=Duel.GetOperatedGroup()
		if og:GetFirst():IsLocation(LOCATION_EXTRA) then
			local tc=g2:GetFirst()
			if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				tc:RegisterEffect(e1)
				local e2=Effect.CreateEffect(e:GetHandler())
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				tc:RegisterEffect(e2)
			end
		end
	end
end