--ゴーストリック・ガーデン
--Ghostrick Garden
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e0)
	--Once while face-up on the field, during your Main Phase: You can add 1 "Ghostrick" monster from your Deck to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--If a monster(s) is sent to the GY by an opponent's card effect: You can activate 1 of these effects;
	--● Change 1 face-up or face-down "Ghostrick" monster you control to face-up or face-down Defense Position
	--● Attach the top card of your Deck to 1 "Ghostrick" Xyz Monster you control
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(s.effcon)
	e2:SetTarget(s.efftg)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_GHOSTRICK}
function s.thfilter(c)
	return c:IsSetCard(SET_GHOSTRICK) and c:IsMonster() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.effconfilter(c)
	return c:IsMonster() and c:IsReason(REASON_EFFECT)
end
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and eg:IsExists(s.effconfilter,1,nil)
end
function s.posfilter(c)
	if not c:IsSetCard(SET_GHOSTRICK) then return false end
	if c:IsPosition(POS_FACEUP_DEFENSE) then
		return c:IsCanTurnSet()
	else
		return c:IsCanChangePosition() or c:IsCanTurnSet()
	end
end
function s.attachfilter(c,top_card,tp)
	return c:IsSetCard(SET_GHOSTRICK) and c:IsXyzMonster() and c:IsFaceup() and top_card:IsCanBeXyzMaterial(c,tp,REASON_EFFECT)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	--● Change 1 face-up or face-down "Ghostrick" monster you control to face-up or face-down Defense Position
	local option_1=Duel.IsExistingMatchingCard(s.posfilter,tp,LOCATION_MZONE,0,1,nil)
	--● Attach the top card of your Deck to 1 "Ghostrick" Xyz Monster you control
	local top_card=Duel.GetDecktopGroup(tp,1):GetFirst()
	local option_2=top_card and Duel.IsExistingMatchingCard(s.attachfilter,tp,LOCATION_MZONE,0,1,nil,top_card,tp)
	if chk==0 then return option_1 or option_2 end
	local choice=Duel.SelectEffect(tp,
		{option_1,aux.Stringid(id,2)},
		{option_2,aux.Stringid(id,3)})
	e:GetChainData().choice=choice
	if choice==1 then
		--● Change 1 face-up or face-down "Ghostrick" monster you control to face-up or face-down Defense Position
		e:SetCategory(CATEGORY_POSITION+CATEGORY_SET)
		Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,tp,LOCATION_MZONE)
	elseif choice==2 then
		--● Attach the top card of your Deck to 1 "Ghostrick" Xyz Monster you control
		e:SetCategory(0)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local choice=e:GetChainData().choice
	if choice==1 then
		--● Change 1 face-up or face-down "Ghostrick" monster you control to face-up or face-down Defense Position
		 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
		local sc=Duel.SelectMatchingCard(tp,s.posfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
		if sc then
			Duel.HintSelection(sc)
			local position=0
			if sc:IsFacedown() then
				position=POS_FACEUP_DEFENSE
			elseif sc:IsDefensePos() then
				position=POS_FACEDOWN_DEFENSE
			else
				if sc:IsCanChangePosition() then
					position=POS_FACEUP_DEFENSE
				end
				if sc:IsCanTurnSet() then
					position=position|POS_FACEDOWN_DEFENSE
				end
				position=Duel.SelectPosition(tp,sc,position)
			end
			Duel.ChangePosition(sc,position)
		end
	elseif choice==2 then
		--● Attach the top card of your Deck to 1 "Ghostrick" Xyz Monster you control
		local top_card=Duel.GetDecktopGroup(tp,1):GetFirst()
		if not top_card then return end
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,4))
		local xyzc=Duel.SelectMatchingCard(tp,s.attachfilter,tp,LOCATION_MZONE,0,1,1,nil,top_card,tp):GetFirst()
		if xyzc then
			Duel.HintSelection(xyzc)
			Duel.DisableShuffleCheck()
			Duel.Overlay(xyzc,top_card)
		end
	end
end