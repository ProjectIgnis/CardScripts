--JP name
--Genia of the Ring
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--If this card is in your hand: You can target 1 face-up monster on the field; Special Summon this card, also that target becomes a Spellcaster monster. The next time that target would be destroyed by card effect this turn, it is not destroyed, also you cannot Special Summon from the Extra Deck for the rest of this turn, except Spellcaster monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--If this card is Tributed, or banished, to activate a Spellcaster monster's effect: You can add this card to your hand
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,1))
	e2a:SetCategory(CATEGORY_TOHAND)
	e2a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2a:SetProperty(EFFECT_FLAG_DELAY)
	e2a:SetCode(EVENT_RELEASE)
	e2a:SetCountLimit(1,{id,1})
	e2a:SetCondition(s.thcon)
	e2a:SetTarget(s.thtg)
	e2a:SetOperation(s.thop)
	c:RegisterEffect(e2a)
	local e2b=e2a:Clone()
	e2b:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e2b)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_APPLYTO)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		if tc:IsRaceExcept(RACE_SPELLCASTER) then
			--That target becomes a Spellcaster monster
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CHANGE_RACE)
			e1:SetValue(RACE_SPELLCASTER)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
		--The next time that target would be destroyed by card effect this turn, it is not destroyed
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id,2))
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
		e2:SetCountLimit(1)
		e2:SetValue(function(e,re,r,rp) if r&REASON_EFFECT>0 then e:Reset() return true end end)
		e2:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e2)
	end
	--You cannot Special Summon from the Extra Deck for the rest of this turn, except Spellcaster monsters
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetTargetRange(1,0)
	e3:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) and c:IsRaceExcept(RACE_SPELLCASTER) end)
	e3:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e3,tp)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	if not (e:GetHandler():IsReason(REASON_COST) and re and re:IsActivated() and re:IsMonsterEffect()) then return false end
	local rc=re:GetHandler()
	if rc:IsRelateToEffect(re) and rc:IsFaceup() then
		return rc:IsRace(RACE_SPELLCASTER)
	else
		return Duel.GetChainInfo(0,CHAININFO_TRIGGERING_RACE)&RACE_SPELLCASTER>0
	end
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,tp,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end