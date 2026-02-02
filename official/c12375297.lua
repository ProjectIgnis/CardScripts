--燿ける聖詩の獄神精
--Elfnote Power Patron
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--You cannot Special Summon from the Extra Deck, except Synchro Monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsSynchroMonster() end)
	c:RegisterEffect(e1)
	aux.addContinuousLizardCheck(c,LOCATION_MZONE,function(e,c) return not c:IsOriginalType(TYPE_SYNCHRO) end)
	--Increase the Level of the monster in your center Main Monster Zone by 3 (until the end of this turn), then immediately after this effect resolves, you can Synchro Summon 1 "Elfnote" monster or "Junora the Power Patron of Tuning"
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_LVCHANGE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function() return Duel.IsMainPhase() end)
	e2:SetTarget(s.lvtg)
	e2:SetOperation(s.lvop)
	e2:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e2)
	--Add 1 "Elfnote" card from your Deck to your hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO end)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_ELFNOTE}
s.listed_names={5914858} --"Junora the Power Patron of Tuning"
function s.lvfilter(c)
	return c:IsSequence(2) and c:HasLevel() and c:IsFaceup()
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MMZONE) and s.lvfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.lvfilter,tp,LOCATION_MMZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MMZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_LVCHANGE,g,1,tp,3)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.synchrofilter(c)
	return (c:IsSetCard(SET_ELFNOTE) or c:IsCode(5914858)) and c:IsSynchroSummonable()
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local prev_lv=tc:GetLevel()
		--Increase its Level by 3
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(3)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
		Duel.AdjustInstantly(tc)
		if not tc:IsLevel(prev_lv+3) then return end
		local g=Duel.GetMatchingGroup(s.synchrofilter,tp,LOCATION_EXTRA,0,1,nil)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sc=g:Select(tp,1,1,nil):GetFirst()
			Duel.SynchroSummon(tp,sc)
		end
	end
end
function s.thfilter(c)
	return c:IsSetCard(SET_ELFNOTE) and c:IsAbleToHand()
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