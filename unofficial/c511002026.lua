--Sphin-Quiz
local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(s.sumcon)
	e1:SetTarget(s.sumtg)
	e1:SetOperation(s.sumop)
	c:RegisterEffect(e1)
	--cannot be battle target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e2:SetCondition(s.con)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--Quest
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(95100088,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.qcon)
	e3:SetOperation(s.qop)
	c:RegisterEffect(e3)
end
function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=eg:GetFirst()
	return rc:IsSetCard(0x541)
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x541)
end
function s.con(e)
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
function s.qcon(e,tp,eg,ep,ev,re,r,rp)
	local bt=eg:GetFirst()
	return r~=REASON_REPLACE and bt:IsSetCard(0x541)
end
function s.qop(e,tp,eg,ep,ev,re,r,rp)
	local ghd=Duel.GetFieldGroup(tp,LOCATION_HAND+LOCATION_DECK,LOCATION_HAND+LOCATION_DECK)
	local gex=Duel.GetFieldGroup(tp,LOCATION_EXTRA,LOCATION_EXTRA)
	if #ghd==0 and #gex==0 then return end
	local op=0
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(4003,14))
	if #ghd>0 and #gex>0 then
		op=Duel.SelectOption(tp,aux.Stringid(4003,11),aux.Stringid(4003,12),aux.Stringid(4003,13))
	elseif #ghd>0 then
		Duel.SelectOption(tp,aux.Stringid(4003,11))
		op=0
	else
		op=Duel.SelectOption(tp,aux.Stringid(4003,12),aux.Stringid(4003,13))
		op=op+1
	end
	local lv=0
	local quest=0
	if op==0 then
		Duel.Hint(HINT_MESSAGE,1-tp,aux.Stringid(4003,11))
		Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(4003,11))
		quest=Duel.AnnounceNumber(1-tp,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15)
		lv=ghd:GetMaxGroup(Card.GetLevel):GetFirst():GetLevel()
		Duel.ConfirmCards(1-tp,ghd)
		Duel.ConfirmCards(tp,ghd)
		Duel.ShuffleDeck(tp)
		Duel.ShuffleDeck(1-tp)
		Duel.ShuffleHand(tp)
		Duel.ShuffleHand(1-tp)
	elseif op==1 then
		Duel.Hint(HINT_MESSAGE,1-tp,aux.Stringid(4003,12))
		Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(4003,12))
		quest=Duel.AnnounceNumber(1-tp,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15)
		lv=gex:GetMaxGroup(Card.GetLevel):GetFirst():GetLevel()
		Duel.ConfirmCards(1-tp,gex)
		Duel.ConfirmCards(tp,gex)
	else
		Duel.Hint(HINT_MESSAGE,1-tp,aux.Stringid(4003,13))
		Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(4003,13))
		quest=Duel.AnnounceNumber(1-tp,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15)
		lv=gex:GetMaxGroup(Card.GetRank):GetFirst():GetRank()
		Duel.ConfirmCards(1-tp,gex)
		Duel.ConfirmCards(tp,gex)
	end
	if quest==lv then
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		if #g>0 then
			local tg=g:GetMaxGroup(Card.GetAttack)
			if #tg>1 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
				tg=tg:Select(tp,1,1,nil)
				Duel.HintSelection(tg)
			end
			if Duel.Destroy(tg,REASON_EFFECT)>0 then
				Duel.Damage(tg:GetFirst():GetPreviousControler(),tg:GetFirst():GetAttack(),REASON_EFFECT)
			end
		end
	else
		Duel.SkipPhase(Duel.GetTurnPlayer(),PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE,1)
	end
end
