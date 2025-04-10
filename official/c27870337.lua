--ドレミコード・エレガンス
--Solfachord Elegance
--Scripted by Hel
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_LIMIT_ZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetValue(s.zones)
	c:RegisterEffect(e1)
end
s.listed_series={SET_SOLFACHORD}
function s.zones(e,tp,eg,ep,ev,re,r,rp)
	local zone=0xff --all S/T zones
	local place_g=Duel.GetMatchingGroup(s.plfilter,tp,LOCATION_DECK,0,nil)
	local left_pend=Duel.CheckLocation(tp,LOCATION_PZONE,0)
	local right_pend=Duel.CheckLocation(tp,LOCATION_PZONE,1)
	local b1=Duel.CheckPendulumZones(tp) and #place_g>0
	local b2=Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_HAND,0,1,nil) and left_pend and right_pend
		and aux.SelectUnselectGroup(place_g,e,tp,2,2,s.rescon,0,tp,nil)
	if b1 and not b2 and not (left_pend and right_pend) then
		zone=0xe --S/T zones without the right and left most ones
	end
	return zone
end
function s.plfilter(c)
	return c:IsSetCard(SET_SOLFACHORD) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(Card.IsEvenScale,1,nil) and sg:IsExists(Card.IsOddScale,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local place_g=Duel.GetMatchingGroup(s.plfilter,tp,LOCATION_DECK,0,nil)
	local toextra_g=Duel.GetMatchingGroup(aux.NOT(Card.IsForbidden),tp,LOCATION_PZONE,0,nil)
	local b1=Duel.CheckPendulumZones(tp) and #place_g>0
	local b2=Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_HAND,0,1,nil)
		and Duel.CheckLocation(tp,LOCATION_PZONE,0) and Duel.CheckLocation(tp,LOCATION_PZONE,1)
		and aux.SelectUnselectGroup(place_g,e,tp,2,2,s.rescon,0,tp,nil)
	local b3=Duel.IsPlayerCanDraw(tp,2) and aux.SelectUnselectGroup(toextra_g,e,tp,2,2,s.rescon,0,tp,nil)
	if chk==0 then return b1 or b2 or b3 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)},
		{b3,aux.Stringid(id,3)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(0)
	elseif op==2 then
		e:SetCategory(CATEGORY_TOEXTRA)
		Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_HAND)
	elseif op==3 then
		e:SetCategory(CATEGORY_TOEXTRA+CATEGORY_DRAW)
		Duel.SetTargetPlayer(tp)
		Duel.SetTargetParam(2)
		Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,2,tp,LOCATION_PZONE)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--Place 1 "Solfachord" Pendulum Monster from your Deck in your Pendulum Zone
		if not Duel.CheckPendulumZones(tp) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local sc=Duel.SelectMatchingCard(tp,s.plfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
		if sc then
			Duel.MoveToField(sc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end
	elseif op==2 then
		--Place 2 "Solfachord" Pendulum Monsters from your Deck in your Pendulum Zone
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,4))
		local g=Duel.SelectMatchingCard(tp,s.plfilter,tp,LOCATION_HAND,0,1,1,nil)
		if not (Duel.SendtoExtraP(g,tp,REASON_EFFECT)>0 and Duel.CheckLocation(tp,LOCATION_PZONE,0) and Duel.CheckLocation(tp,LOCATION_PZONE,1)) then return end
		local place_g=Duel.GetMatchingGroup(s.plfilter,tp,LOCATION_DECK,0,nil)
		if #place_g<2 then return end
		local sg=aux.SelectUnselectGroup(place_g,e,tp,2,2,s.rescon,1,tp,HINTMSG_TOFIELD)
		if #sg==2 then
			Duel.BreakEffect()
			Duel.MoveToField(sg:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
			Duel.MoveToField(sg:GetNext(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end
	elseif op==3 then
		--Add 2 Pendulum Scales to the Extra Deck face-up and draw 2 cards
		local toextra_g=Duel.GetMatchingGroup(aux.NOT(Card.IsForbidden),tp,LOCATION_PZONE,0,nil)
		if #toextra_g==2 and aux.SelectUnselectGroup(toextra_g,e,tp,2,2,s.rescon,0,tp,nil) and Duel.SendtoExtraP(toextra_g,tp,REASON_EFFECT)>0
			and Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)==2 then
			local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
			Duel.Draw(p,d,REASON_EFFECT)
		end
	end
end