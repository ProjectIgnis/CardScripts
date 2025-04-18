--超勝負！
--Super All In!
--Logical Nonsense
--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Return synchro to extra deck, special summon 4 "Flower Cardian" monsters from GY, draw 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Indicate the fact it was sent to GY this turn by "Flower Cardian" monster effect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(s.thcon)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
	--Lists the "Flower Cardian" archetype
s.listed_series={SET_FLOWER_CARDIAN}
	--Check for synchro monster
function s.exfilter(c,tp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsAbleToHand()
		and ((c:GetSequence()<5 and ft>2) or ft>3)
end
	--Check for "Flower Cardian" monsters that can be special summoned
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_FLOWER_CARDIAN) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
	--Activation legality
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_MZONE,0,1,nil,tp)
		and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,4,nil,e,tp)
		and Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,4,tp,LOCATION_GRAVE)
end
	--Return synchro to extra deck, special summon 4 "Flower Cardian" monsters from GY, draw 1
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp,s.exfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	local td=g:GetFirst()
	if td and Duel.SendtoHand(td,nil,REASON_EFFECT)~=0 and td:IsLocation(LOCATION_EXTRA) then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<4 or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,4,4,nil,e,tp)
		if #sg>0 and Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)~=0 then
			Duel.BreakEffect()
			local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
			if Duel.Draw(tp,1,REASON_EFFECT)==0 then return end
			local tc=Duel.GetOperatedGroup():GetFirst()
			Duel.ConfirmCards(1-tp,tc)
			if tc:IsMonster() and tc:IsSetCard(SET_FLOWER_CARDIAN) then
				if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
					Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
				end
			else --If drawn card was not a "Flower Cardian" monster, destroy all monster you control and halve your LP
				local dg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,nil)
				Duel.Destroy(dg,REASON_EFFECT)
				if #Duel.GetOperatedGroup()>0 then
					local lp=Duel.GetLP(tp)
					Duel.SetLP(tp,math.ceil(lp/2))
				end
			end
		end
	end
end
	--Check for spell/trap card
function s.addfilter(c)
	return c:IsSpellTrap() and c:IsAbleToHand()
end
	--If sent to GY by "Flower Cardian" monster effect
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	return e:GetHandler():IsReason(REASON_EFFECT) and rc:IsSetCard(SET_FLOWER_CARDIAN) and rc:IsMonster()
end
	--Add 1 spell/trap card from GY to hand
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.addtg)
	e1:SetOperation(s.addop)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	c:RegisterEffect(e1)
end
	--Activation legality
function s.addtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.addfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
	--Add 1 spell/trap card from GY to hand
function s.addop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.addfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end